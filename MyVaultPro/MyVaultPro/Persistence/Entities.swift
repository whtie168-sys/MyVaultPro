//
//  Entities.swift
//  MyVaultPro
//
//  Core Data managed object subclasses. The model itself is built
//  programmatically in PersistenceController, so there is no .xcdatamodeld file.
//

import Foundation
import CoreData

// MARK: - Asset

@objc(Asset)
public final class Asset: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchasePrice: Double
    @NSManaged public var currentValue: Double
    @NSManaged public var serialNumber: String?
    @NSManaged public var warrantyExpiration: Date?
    @NSManaged public var notes: String?
    @NSManaged public var photo: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

// MARK: - CollectionItem

@objc(CollectionItem)
public final class CollectionItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var estimatedValue: Double
    @NSManaged public var condition: String
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var photo: Data?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

// MARK: - DocumentRecord

@objc(DocumentRecord)
public final class DocumentRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var category: String
    @NSManaged public var issueDate: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var attachmentReference: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

// MARK: - SubscriptionItem

@objc(SubscriptionItem)
public final class SubscriptionItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var serviceName: String
    @NSManaged public var cost: Double
    @NSManaged public var billingCycle: String
    @NSManaged public var renewalDate: Date?
    @NSManaged public var category: String
    @NSManaged public var notes: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

// MARK: - MaintenanceRecord

@objc(MaintenanceRecord)
public final class MaintenanceRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var itemName: String
    @NSManaged public var maintenanceDate: Date?
    @NSManaged public var cost: Double
    @NSManaged public var type: String
    @NSManaged public var notes: String?
    @NSManaged public var nextDueDate: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}
