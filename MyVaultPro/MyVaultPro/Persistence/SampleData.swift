//
//  SampleData.swift
//  MyVaultPro
//
//  Seeds a rich set of demo records on first launch so the dashboard
//  never looks empty — matching the "no empty screens" design goal.
//

import Foundation
import CoreData

enum SampleData {
    static func seedIfNeeded(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.fetchLimit = 1
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }
        seed(in: context)
    }

    static func seed(in context: NSManagedObjectContext) {
        let now = Date()
        let cal = Calendar.current
        func daysFromNow(_ d: Int) -> Date { cal.date(byAdding: .day, value: d, to: now) ?? now }
        func monthsAgo(_ m: Int) -> Date { cal.date(byAdding: .month, value: -m, to: now) ?? now }

        // MARK: Assets
        let assets: [(String, AssetCategory, Double, Double, Int, Int?, String)] = [
            ("MacBook Pro 16\"", .electronics, 2499, 2100, 8, 16, "C02XXXXX1"),
            ("iPhone 15 Pro", .electronics, 1199, 1000, 5, 7, "F2LXXXXX2"),
            ("Sony A7 IV", .equipment, 2498, 2300, 14, 10, "SN-A7-993"),
            ("Tesla Model 3", .vehicle, 42990, 38000, 26, 48, "5YJ3E1EA"),
            ("Herman Miller Aeron", .furniture, 1395, 1200, 18, nil, "HM-AER-22"),
            ("Apple Watch Ultra 2", .jewelry, 799, 720, 3, 11, "GX1XXXXX")
        ]
        for (name, cat, price, value, agoMonths, warrantyMonths, serial) in assets {
            let a = Asset(context: context)
            a.id = UUID(); a.name = name; a.category = cat.rawValue
            a.purchasePrice = price; a.currentValue = value
            a.purchaseDate = monthsAgo(agoMonths)
            a.serialNumber = serial
            if let w = warrantyMonths { a.warrantyExpiration = cal.date(byAdding: .month, value: w, to: monthsAgo(agoMonths)) }
            a.notes = ""
            a.createdAt = monthsAgo(agoMonths); a.updatedAt = daysFromNow(-(agoMonths))
        }

        // MARK: Collection items
        let collectibles: [(String, CollectionCategory, Double, ItemCondition)] = [
            ("Charizard 1st Edition", .tradingCards, 3200, .excellent),
            ("Omega Speedmaster", .watches, 5800, .mint),
            ("The Hobbit First Print", .books, 1400, .good),
            ("1933 Double Eagle", .coins, 9500, .excellent),
            ("Zelda: TOTK Collector's", .games, 130, .mint),
            ("Iron Man Mark III Figure", .figures, 280, .good),
            ("Amazing Fantasy #15", .comics, 4200, .fair)
        ]
        for (name, cat, value, condition) in collectibles {
            let c = CollectionItem(context: context)
            c.id = UUID(); c.name = name; c.category = cat.rawValue
            c.estimatedValue = value; c.condition = condition.rawValue
            c.purchaseDate = monthsAgo(Int.random(in: 1...24) % 24 + 1)
            c.notes = ""
            c.createdAt = monthsAgo(Int.random(in: 0...11) % 11 + 1); c.updatedAt = c.createdAt
        }

        // MARK: Documents
        let documents: [(String, DocumentCategory, Int?, Int?)] = [
            ("US Passport", .passport, -40, 1500),
            ("Home Insurance Policy", .insurance, -120, 245),
            ("MacBook AppleCare", .warranty, -240, 360),
            ("Car Lease Contract", .contract, -200, 530),
            ("University Diploma", .certificate, -2000, nil),
            ("Driver's License", .id, -700, 60)
        ]
        for (title, cat, issueOffset, expOffset) in documents {
            let d = DocumentRecord(context: context)
            d.id = UUID(); d.title = title; d.category = cat.rawValue
            if let issueOffset { d.issueDate = daysFromNow(issueOffset) }
            if let expOffset { d.expirationDate = daysFromNow(expOffset) }
            d.notes = ""
            d.createdAt = daysFromNow(issueOffset ?? -10); d.updatedAt = d.createdAt
        }

        // MARK: Subscriptions
        let subs: [(String, Double, BillingCycle, SubscriptionCategory, Int)] = [
            ("Netflix", 15.49, .monthly, .entertainment, 12),
            ("Spotify", 10.99, .monthly, .music, 5),
            ("Adobe Creative Cloud", 59.99, .monthly, .productivity, 21),
            ("iCloud+ 2TB", 9.99, .monthly, .cloud, 3),
            ("ChatGPT Plus", 20.00, .monthly, .productivity, 8),
            ("Gym Membership", 480.00, .yearly, .fitness, 95)
        ]
        for (name, cost, cycle, cat, renewIn) in subs {
            let s = SubscriptionItem(context: context)
            s.id = UUID(); s.serviceName = name; s.cost = cost
            s.billingCycle = cycle.rawValue; s.category = cat.rawValue
            s.renewalDate = daysFromNow(renewIn); s.isActive = true
            s.notes = ""
            s.createdAt = monthsAgo(6); s.updatedAt = s.createdAt
        }

        // MARK: Maintenance
        let maint: [(String, MaintenanceType, Double, Int, Int?)] = [
            ("Tesla Model 3", .service, 220, -30, 150),
            ("MacBook Pro", .repair, 180, -90, nil),
            ("Road Bike", .service, 75, -14, 75),
            ("HVAC System", .inspection, 120, -60, 120)
        ]
        for (item, type, cost, dateOffset, nextOffset) in maint {
            let m = MaintenanceRecord(context: context)
            m.id = UUID(); m.itemName = item; m.type = type.rawValue
            m.cost = cost; m.maintenanceDate = daysFromNow(dateOffset)
            if let nextOffset { m.nextDueDate = daysFromNow(nextOffset) }
            m.notes = ""
            m.createdAt = daysFromNow(dateOffset); m.updatedAt = m.createdAt
        }

        do { try context.save() } catch {
            assertionFailure("Sample seed failed: \(error)")
        }
    }
}
