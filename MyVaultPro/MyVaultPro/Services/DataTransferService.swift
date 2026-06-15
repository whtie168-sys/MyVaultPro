//
//  DataTransferService.swift
//  MyVaultPro
//
//  JSON export/import of the entire vault. Photos are encoded as base64.
//

import Foundation
import CoreData

// MARK: - Transfer DTOs

struct VaultExport: Codable {
    var version: Int = 1
    var exportedAt: Date = Date()
    var assets: [AssetDTO] = []
    var collections: [CollectionDTO] = []
    var documents: [DocumentDTO] = []
    var subscriptions: [SubscriptionDTO] = []
    var maintenance: [MaintenanceDTO] = []
}

struct AssetDTO: Codable {
    var id: UUID, name: String, category: String
    var purchaseDate: Date?, purchasePrice: Double, currentValue: Double
    var serialNumber: String?, warrantyExpiration: Date?, notes: String?
    var photo: Data?
    var createdAt: Date, updatedAt: Date
}

struct CollectionDTO: Codable {
    var id: UUID, name: String, category: String
    var estimatedValue: Double, condition: String
    var purchaseDate: Date?, notes: String?, photo: Data?
    var createdAt: Date, updatedAt: Date
}

struct DocumentDTO: Codable {
    var id: UUID, title: String, category: String
    var issueDate: Date?, expirationDate: Date?, notes: String?, attachmentReference: String?
    var createdAt: Date, updatedAt: Date
}

struct SubscriptionDTO: Codable {
    var id: UUID, serviceName: String, cost: Double, billingCycle: String
    var renewalDate: Date?, category: String, notes: String?, isActive: Bool
    var createdAt: Date, updatedAt: Date
}

struct MaintenanceDTO: Codable {
    var id: UUID, itemName: String, maintenanceDate: Date?, cost: Double
    var type: String, notes: String?, nextDueDate: Date?
    var createdAt: Date, updatedAt: Date
}

// MARK: - Service

enum DataTransferService {
    static func makeEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }

    static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    static func export(from store: DataStore) throws -> Data {
        var export = VaultExport()
        export.assets = store.assets.map {
            AssetDTO(id: $0.id, name: $0.name, category: $0.category,
                     purchaseDate: $0.purchaseDate, purchasePrice: $0.purchasePrice,
                     currentValue: $0.currentValue, serialNumber: $0.serialNumber,
                     warrantyExpiration: $0.warrantyExpiration, notes: $0.notes,
                     photo: $0.photo, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        export.collections = store.collections.map {
            CollectionDTO(id: $0.id, name: $0.name, category: $0.category,
                          estimatedValue: $0.estimatedValue, condition: $0.condition,
                          purchaseDate: $0.purchaseDate, notes: $0.notes, photo: $0.photo,
                          createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        export.documents = store.documents.map {
            DocumentDTO(id: $0.id, title: $0.title, category: $0.category,
                        issueDate: $0.issueDate, expirationDate: $0.expirationDate,
                        notes: $0.notes, attachmentReference: $0.attachmentReference,
                        createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        export.subscriptions = store.subscriptions.map {
            SubscriptionDTO(id: $0.id, serviceName: $0.serviceName, cost: $0.cost,
                            billingCycle: $0.billingCycle, renewalDate: $0.renewalDate,
                            category: $0.category, notes: $0.notes, isActive: $0.isActive,
                            createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        export.maintenance = store.maintenance.map {
            MaintenanceDTO(id: $0.id, itemName: $0.itemName, maintenanceDate: $0.maintenanceDate,
                           cost: $0.cost, type: $0.type, notes: $0.notes,
                           nextDueDate: $0.nextDueDate, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        return try makeEncoder().encode(export)
    }

    /// Imports records, skipping any IDs that already exist (merge, non-destructive).
    @discardableResult
    static func `import`(data: Data, into store: DataStore) throws -> Int {
        let payload = try makeDecoder().decode(VaultExport.self, from: data)
        let context = store.context
        var imported = 0

        var existingIDs = Set<UUID>()
        existingIDs.formUnion(store.assets.map(\.id))
        existingIDs.formUnion(store.collections.map(\.id))
        existingIDs.formUnion(store.documents.map(\.id))
        existingIDs.formUnion(store.subscriptions.map(\.id))
        existingIDs.formUnion(store.maintenance.map(\.id))

        for dto in payload.assets where !existingIDs.contains(dto.id) {
            let a = Asset(context: context)
            a.id = dto.id; a.name = dto.name; a.category = dto.category
            a.purchaseDate = dto.purchaseDate; a.purchasePrice = dto.purchasePrice
            a.currentValue = dto.currentValue; a.serialNumber = dto.serialNumber
            a.warrantyExpiration = dto.warrantyExpiration; a.notes = dto.notes
            a.photo = dto.photo; a.createdAt = dto.createdAt; a.updatedAt = dto.updatedAt
            imported += 1
        }
        for dto in payload.collections where !existingIDs.contains(dto.id) {
            let c = CollectionItem(context: context)
            c.id = dto.id; c.name = dto.name; c.category = dto.category
            c.estimatedValue = dto.estimatedValue; c.condition = dto.condition
            c.purchaseDate = dto.purchaseDate; c.notes = dto.notes; c.photo = dto.photo
            c.createdAt = dto.createdAt; c.updatedAt = dto.updatedAt
            imported += 1
        }
        for dto in payload.documents where !existingIDs.contains(dto.id) {
            let d = DocumentRecord(context: context)
            d.id = dto.id; d.title = dto.title; d.category = dto.category
            d.issueDate = dto.issueDate; d.expirationDate = dto.expirationDate
            d.notes = dto.notes; d.attachmentReference = dto.attachmentReference
            d.createdAt = dto.createdAt; d.updatedAt = dto.updatedAt
            imported += 1
        }
        for dto in payload.subscriptions where !existingIDs.contains(dto.id) {
            let s = SubscriptionItem(context: context)
            s.id = dto.id; s.serviceName = dto.serviceName; s.cost = dto.cost
            s.billingCycle = dto.billingCycle; s.renewalDate = dto.renewalDate
            s.category = dto.category; s.notes = dto.notes; s.isActive = dto.isActive
            s.createdAt = dto.createdAt; s.updatedAt = dto.updatedAt
            imported += 1
        }
        for dto in payload.maintenance where !existingIDs.contains(dto.id) {
            let m = MaintenanceRecord(context: context)
            m.id = dto.id; m.itemName = dto.itemName; m.maintenanceDate = dto.maintenanceDate
            m.cost = dto.cost; m.type = dto.type; m.notes = dto.notes
            m.nextDueDate = dto.nextDueDate; m.createdAt = dto.createdAt; m.updatedAt = dto.updatedAt
            imported += 1
        }

        store.saveAndRefresh()
        return imported
    }
}
