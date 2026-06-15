//
//  DataStore.swift
//  MyVaultPro
//
//  Central MVVM store. Owns the Core Data context, performs CRUD,
//  and exposes aggregate statistics used by the dashboard & stats screens.
//

import SwiftUI
import CoreData
import Combine

@MainActor
final class DataStore: ObservableObject {
    let context: NSManagedObjectContext

    /// Bumped whenever data changes so dependent views recompute stats.
    @Published private(set) var revision = 0

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Persistence

    func saveAndRefresh() {
        do {
            if context.hasChanges { try context.save() }
        } catch {
            assertionFailure("Save failed: \(error)")
        }
        revision &+= 1
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveAndRefresh()
    }

    // MARK: - Fetch convenience

    func all<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        (try? context.fetch(request)) ?? []
    }

    var assets: [Asset] { all(Asset.fetchAll()) }
    var collections: [CollectionItem] { all(CollectionItem.fetchAll()) }
    var documents: [DocumentRecord] { all(DocumentRecord.fetchAll()) }
    var subscriptions: [SubscriptionItem] { all(SubscriptionItem.fetchAll()) }
    var maintenance: [MaintenanceRecord] { all(MaintenanceRecord.fetchAll()) }

    // MARK: - Dashboard aggregates

    var totalAssets: Int { assets.count }
    var totalCollections: Int { collections.count }
    var totalDocuments: Int { documents.count }
    var activeSubscriptions: Int { subscriptions.filter(\.isActive).count }

    var totalAssetValue: Double { assets.reduce(0) { $0 + $1.currentValue } }
    var totalCollectionValue: Double { collections.reduce(0) { $0 + $1.estimatedValue } }
    var totalPortfolioValue: Double { totalAssetValue + totalCollectionValue }

    var monthlySubscriptionCost: Double {
        subscriptions.filter(\.isActive).reduce(0) { $0 + $1.monthlyCost }
    }

    var yearlyMaintenanceCost: Double {
        let cal = Calendar.current
        let oneYearAgo = cal.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return maintenance
            .filter { ($0.maintenanceDate ?? .distantPast) >= oneYearAgo }
            .reduce(0) { $0 + $1.cost }
    }

    // MARK: - Upcoming events (warranties, documents, renewals, maintenance)

    func upcomingEvents(within days: Int = 365) -> [UpcomingEvent] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let horizon = cal.date(byAdding: .day, value: days, to: today) ?? today
        var events: [UpcomingEvent] = []

        for a in assets {
            if let w = a.warrantyExpiration, w >= today, w <= horizon {
                events.append(UpcomingEvent(id: a.id, title: "\(a.name) warranty", kind: .warranty, date: w))
            }
        }
        for d in documents {
            if let e = d.expirationDate, e >= today, e <= horizon {
                events.append(UpcomingEvent(id: d.id, title: d.title, kind: .document, date: e))
            }
        }
        for s in subscriptions where s.isActive {
            if let r = s.renewalDate, r >= today, r <= horizon {
                events.append(UpcomingEvent(id: s.id, title: s.serviceName, kind: .subscription, date: r))
            }
        }
        for m in maintenance {
            if let n = m.nextDueDate, n >= today, n <= horizon {
                events.append(UpcomingEvent(id: m.id, title: m.itemName, kind: .maintenance, date: n))
            }
        }
        return events.sorted { $0.date < $1.date }
    }

    var recentlyAdded: [RecentActivity] {
        var items: [RecentActivity] = []
        items += assets.map { RecentActivity(id: $0.id, title: $0.name, subtitle: "Asset", icon: $0.categoryEnum.icon, tint: $0.categoryEnum.tint, date: $0.createdAt) }
        items += collections.map { RecentActivity(id: $0.id, title: $0.name, subtitle: "Collection", icon: $0.categoryEnum.icon, tint: $0.categoryEnum.tint, date: $0.createdAt) }
        items += documents.map { RecentActivity(id: $0.id, title: $0.title, subtitle: "Document", icon: $0.categoryEnum.icon, tint: $0.categoryEnum.tint, date: $0.createdAt) }
        items += subscriptions.map { RecentActivity(id: $0.id, title: $0.serviceName, subtitle: "Subscription", icon: $0.categoryEnum.icon, tint: $0.categoryEnum.tint, date: $0.createdAt) }
        return items.sorted { $0.date > $1.date }
    }

    // MARK: - Distributions for charts

    func assetCategoryDistribution() -> [ChartDatum] {
        let grouped = Dictionary(grouping: assets, by: { $0.categoryEnum })
        return AssetCategory.allCases.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return ChartDatum(label: shortLabel(cat.rawValue), value: Double(items.count), tint: cat.tint)
        }
    }

    func collectionValueByCategory() -> [DonutSegment] {
        let grouped = Dictionary(grouping: collections, by: { $0.categoryEnum })
        return CollectionCategory.allCases.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            let value = items.reduce(0) { $0 + $1.estimatedValue }
            return DonutSegment(label: cat.rawValue, value: value, tint: cat.tint)
        }
    }

    func subscriptionCostByCategory() -> [ChartDatum] {
        let active = subscriptions.filter(\.isActive)
        let grouped = Dictionary(grouping: active, by: { $0.categoryEnum })
        return SubscriptionCategory.allCases.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            let cost = items.reduce(0) { $0 + $1.monthlyCost }
            return ChartDatum(label: shortLabel(cat.rawValue), value: cost, tint: cat.tint)
        }
    }

    /// Monthly activity over the last 6 months (count of created records).
    func monthlyActivity() -> [ChartDatum] {
        let cal = Calendar.current
        let now = Date()
        var data: [ChartDatum] = []
        let allDates: [Date] = assets.map(\.createdAt) + collections.map(\.createdAt)
            + documents.map(\.createdAt) + subscriptions.map(\.createdAt) + maintenance.map(\.createdAt)
        let fmt = DateFormatter(); fmt.dateFormat = "MMM"
        for offset in stride(from: 5, through: 0, by: -1) {
            guard let monthDate = cal.date(byAdding: .month, value: -offset, to: now) else { continue }
            let comps = cal.dateComponents([.year, .month], from: monthDate)
            let count = allDates.filter {
                let c = cal.dateComponents([.year, .month], from: $0)
                return c.year == comps.year && c.month == comps.month
            }.count
            data.append(ChartDatum(label: fmt.string(from: monthDate), value: Double(count), tint: Theme.teal))
        }
        return data
    }

    private func shortLabel(_ s: String) -> String {
        if s.count <= 6 { return s }
        return String(s.prefix(5)) + "."
    }
}

// MARK: - Recent activity model

struct RecentActivity: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let date: Date
}
