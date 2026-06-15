//
//  Categories.swift
//  MyVaultPro
//
//  Category and enum definitions shared across modules, each with an SF Symbol.
//

import SwiftUI

// MARK: - Asset categories

enum AssetCategory: String, CaseIterable, Identifiable {
    case electronics = "Electronics"
    case vehicle = "Vehicle"
    case furniture = "Furniture"
    case equipment = "Equipment"
    case tools = "Tools"
    case jewelry = "Jewelry"
    case appliance = "Appliance"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .vehicle: return "car.fill"
        case .furniture: return "sofa.fill"
        case .equipment: return "camera.fill"
        case .tools: return "wrench.and.screwdriver.fill"
        case .jewelry: return "applewatch"
        case .appliance: return "washer.fill"
        case .other: return "shippingbox.fill"
        }
    }

    var tint: Color {
        switch self {
        case .electronics: return Theme.indigo
        case .vehicle: return Theme.teal
        case .furniture: return Theme.amber
        case .equipment: return Theme.pink
        case .tools: return Theme.orange
        case .jewelry: return Theme.purple
        case .appliance: return Theme.blue
        case .other: return Theme.green
        }
    }

    static func from(_ raw: String) -> AssetCategory { AssetCategory(rawValue: raw) ?? .other }
}

// MARK: - Collection categories

enum CollectionCategory: String, CaseIterable, Identifiable {
    case books = "Books"
    case tradingCards = "Trading Cards"
    case coins = "Coins"
    case watches = "Watches"
    case games = "Games"
    case figures = "Figures"
    case comics = "Comics"
    case art = "Art"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .books: return "books.vertical.fill"
        case .tradingCards: return "rectangle.on.rectangle.angled.fill"
        case .coins: return "centsign.circle.fill"
        case .watches: return "applewatch"
        case .games: return "gamecontroller.fill"
        case .figures: return "figure.stand"
        case .comics: return "book.fill"
        case .art: return "paintpalette.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .books: return Theme.amber
        case .tradingCards: return Theme.pink
        case .coins: return Theme.orange
        case .watches: return Theme.purple
        case .games: return Theme.indigo
        case .figures: return Theme.teal
        case .comics: return Theme.blue
        case .art: return Theme.green
        case .other: return Theme.slate
        }
    }

    static func from(_ raw: String) -> CollectionCategory { CollectionCategory(rawValue: raw) ?? .other }
}

// MARK: - Condition

enum ItemCondition: String, CaseIterable, Identifiable {
    case mint = "Mint"
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .mint: return Theme.green
        case .excellent: return Theme.teal
        case .good: return Theme.blue
        case .fair: return Theme.amber
        case .poor: return Theme.orange
        }
    }

    static func from(_ raw: String) -> ItemCondition { ItemCondition(rawValue: raw) ?? .good }
}

// MARK: - Document categories

enum DocumentCategory: String, CaseIterable, Identifiable {
    case passport = "Passport"
    case insurance = "Insurance"
    case receipt = "Receipt"
    case warranty = "Warranty"
    case certificate = "Certificate"
    case contract = "Contract"
    case id = "ID Card"
    case other = "Other"

    var identifier: String { rawValue }
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .passport: return "globe"
        case .insurance: return "shield.lefthalf.filled"
        case .receipt: return "receipt.fill"
        case .warranty: return "checkmark.seal.fill"
        case .certificate: return "rosette"
        case .contract: return "doc.text.fill"
        case .id: return "person.text.rectangle.fill"
        case .other: return "doc.fill"
        }
    }

    var tint: Color {
        switch self {
        case .passport: return Theme.blue
        case .insurance: return Theme.teal
        case .receipt: return Theme.amber
        case .warranty: return Theme.green
        case .certificate: return Theme.purple
        case .contract: return Theme.indigo
        case .id: return Theme.pink
        case .other: return Theme.slate
        }
    }

    static func from(_ raw: String) -> DocumentCategory { DocumentCategory(rawValue: raw) ?? .other }
}

// MARK: - Subscription billing cycle

enum BillingCycle: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"

    var id: String { rawValue }

    /// Normalised monthly cost factor used for spend statistics.
    var monthlyFactor: Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1
        case .quarterly: return 1.0 / 3.0
        case .yearly: return 1.0 / 12.0
        }
    }

    static func from(_ raw: String) -> BillingCycle { BillingCycle(rawValue: raw) ?? .monthly }
}

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment = "Entertainment"
    case productivity = "Productivity"
    case music = "Music"
    case cloud = "Cloud Storage"
    case fitness = "Fitness"
    case news = "News"
    case utilities = "Utilities"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .entertainment: return "play.tv.fill"
        case .productivity: return "briefcase.fill"
        case .music: return "music.note"
        case .cloud: return "icloud.fill"
        case .fitness: return "figure.run"
        case .news: return "newspaper.fill"
        case .utilities: return "bolt.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .entertainment: return Theme.pink
        case .productivity: return Theme.indigo
        case .music: return Theme.green
        case .cloud: return Theme.blue
        case .fitness: return Theme.orange
        case .news: return Theme.amber
        case .utilities: return Theme.teal
        case .other: return Theme.slate
        }
    }

    static func from(_ raw: String) -> SubscriptionCategory { SubscriptionCategory(rawValue: raw) ?? .other }
}

// MARK: - Maintenance type

enum MaintenanceType: String, CaseIterable, Identifiable {
    case service = "Service"
    case repair = "Repair"
    case inspection = "Inspection"
    case cleaning = "Cleaning"
    case upgrade = "Upgrade"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .service: return "wrench.fill"
        case .repair: return "hammer.fill"
        case .inspection: return "magnifyingglass"
        case .cleaning: return "sparkles"
        case .upgrade: return "arrow.up.circle.fill"
        case .other: return "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .service: return Theme.teal
        case .repair: return Theme.orange
        case .inspection: return Theme.blue
        case .cleaning: return Theme.green
        case .upgrade: return Theme.purple
        case .other: return Theme.slate
        }
    }

    static func from(_ raw: String) -> MaintenanceType { MaintenanceType(rawValue: raw) ?? .other }
}
