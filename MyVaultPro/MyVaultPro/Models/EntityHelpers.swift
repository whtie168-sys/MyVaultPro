//
//  EntityHelpers.swift
//  MyVaultPro
//
//  Computed helpers, fetch requests, and convenience accessors for entities.
//

import SwiftUI
import CoreData

// MARK: - Fetch requests

extension Asset {
    static func fetchAll() -> NSFetchRequest<Asset> {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return request
    }

    var categoryEnum: AssetCategory { AssetCategory.from(category) }
    var hasWarranty: Bool { warrantyExpiration != nil }
}

extension CollectionItem {
    static func fetchAll() -> NSFetchRequest<CollectionItem> {
        let request = NSFetchRequest<CollectionItem>(entityName: "CollectionItem")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return request
    }

    var categoryEnum: CollectionCategory { CollectionCategory.from(category) }
    var conditionEnum: ItemCondition { ItemCondition.from(condition) }
}

extension DocumentRecord {
    static func fetchAll() -> NSFetchRequest<DocumentRecord> {
        let request = NSFetchRequest<DocumentRecord>(entityName: "DocumentRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return request
    }

    var categoryEnum: DocumentCategory { DocumentCategory.from(category) }
}

extension SubscriptionItem {
    static func fetchAll() -> NSFetchRequest<SubscriptionItem> {
        let request = NSFetchRequest<SubscriptionItem>(entityName: "SubscriptionItem")
        request.sortDescriptors = [NSSortDescriptor(key: "renewalDate", ascending: true)]
        return request
    }

    var categoryEnum: SubscriptionCategory { SubscriptionCategory.from(category) }
    var billingCycleEnum: BillingCycle { BillingCycle.from(billingCycle) }

    /// Cost normalised to a monthly figure for spend totals.
    var monthlyCost: Double { cost * billingCycleEnum.monthlyFactor }
}

extension MaintenanceRecord {
    static func fetchAll() -> NSFetchRequest<MaintenanceRecord> {
        let request = NSFetchRequest<MaintenanceRecord>(entityName: "MaintenanceRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "maintenanceDate", ascending: false)]
        return request
    }

    var typeEnum: MaintenanceType { MaintenanceType.from(type) }
}

// MARK: - Expiration helpers

/// A unified representation of any upcoming dated event for dashboards & reminders.
struct UpcomingEvent: Identifiable {
    enum Kind {
        case warranty, document, subscription, maintenance

        var label: String {
            switch self {
            case .warranty: return "Warranty"
            case .document: return "Document"
            case .subscription: return "Renewal"
            case .maintenance: return "Maintenance"
            }
        }

        var icon: String {
            switch self {
            case .warranty: return "checkmark.seal.fill"
            case .document: return "doc.text.fill"
            case .subscription: return "arrow.triangle.2.circlepath"
            case .maintenance: return "wrench.fill"
            }
        }

        var tint: Color {
            switch self {
            case .warranty: return Theme.green
            case .document: return Theme.blue
            case .subscription: return Theme.pink
            case .maintenance: return Theme.orange
            }
        }
    }

    let id: UUID
    let title: String
    let kind: Kind
    let date: Date

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()),
                                        to: Calendar.current.startOfDay(for: date)).day ?? 0
    }
}

// MARK: - Formatting

enum Format {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f
    }()

    static func money(_ value: Double) -> String {
        currency.string(from: NSNumber(value: value)) ?? "$0"
    }

    static func moneyPrecise(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    static func date(_ date: Date?) -> String {
        guard let date else { return "—" }
        return mediumDate.string(from: date)
    }

    static func relativeDays(_ days: Int) -> String {
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        if days == -1 { return "Yesterday" }
        if days < 0 { return "\(abs(days)) days ago" }
        return "in \(days) days"
    }
}
