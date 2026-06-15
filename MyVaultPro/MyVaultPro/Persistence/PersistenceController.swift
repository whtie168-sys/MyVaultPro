//
//  PersistenceController.swift
//  MyVaultPro
//
//  Builds the Core Data stack with a programmatically-defined model.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        let model = PersistenceController.makeModel()
        container = NSPersistentContainer(name: "MyVaultPro", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // A store failure on a fresh device is non-recoverable; log loudly.
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Failed to save context: \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Model definition

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let asset = entity(
            name: "Asset", className: NSStringFromClass(Asset.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("name", .stringAttributeType),
                attr("category", .stringAttributeType),
                attr("purchaseDate", .dateAttributeType, optional: true),
                attr("purchasePrice", .doubleAttributeType),
                attr("currentValue", .doubleAttributeType),
                attr("serialNumber", .stringAttributeType, optional: true),
                attr("warrantyExpiration", .dateAttributeType, optional: true),
                attr("notes", .stringAttributeType, optional: true),
                attr("photo", .binaryDataAttributeType, optional: true, allowsExternalStorage: true),
                attr("createdAt", .dateAttributeType),
                attr("updatedAt", .dateAttributeType)
            ])

        let collection = entity(
            name: "CollectionItem", className: NSStringFromClass(CollectionItem.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("name", .stringAttributeType),
                attr("category", .stringAttributeType),
                attr("estimatedValue", .doubleAttributeType),
                attr("condition", .stringAttributeType),
                attr("purchaseDate", .dateAttributeType, optional: true),
                attr("photo", .binaryDataAttributeType, optional: true, allowsExternalStorage: true),
                attr("notes", .stringAttributeType, optional: true),
                attr("createdAt", .dateAttributeType),
                attr("updatedAt", .dateAttributeType)
            ])

        let document = entity(
            name: "DocumentRecord", className: NSStringFromClass(DocumentRecord.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("title", .stringAttributeType),
                attr("category", .stringAttributeType),
                attr("issueDate", .dateAttributeType, optional: true),
                attr("expirationDate", .dateAttributeType, optional: true),
                attr("notes", .stringAttributeType, optional: true),
                attr("attachmentReference", .stringAttributeType, optional: true),
                attr("createdAt", .dateAttributeType),
                attr("updatedAt", .dateAttributeType)
            ])

        let subscription = entity(
            name: "SubscriptionItem", className: NSStringFromClass(SubscriptionItem.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("serviceName", .stringAttributeType),
                attr("cost", .doubleAttributeType),
                attr("billingCycle", .stringAttributeType),
                attr("renewalDate", .dateAttributeType, optional: true),
                attr("category", .stringAttributeType),
                attr("notes", .stringAttributeType, optional: true),
                attr("isActive", .booleanAttributeType),
                attr("createdAt", .dateAttributeType),
                attr("updatedAt", .dateAttributeType)
            ])

        let maintenance = entity(
            name: "MaintenanceRecord", className: NSStringFromClass(MaintenanceRecord.self),
            attributes: [
                attr("id", .UUIDAttributeType),
                attr("itemName", .stringAttributeType),
                attr("maintenanceDate", .dateAttributeType, optional: true),
                attr("cost", .doubleAttributeType),
                attr("type", .stringAttributeType),
                attr("notes", .stringAttributeType, optional: true),
                attr("nextDueDate", .dateAttributeType, optional: true),
                attr("createdAt", .dateAttributeType),
                attr("updatedAt", .dateAttributeType)
            ])

        model.entities = [asset, collection, document, subscription, maintenance]
        return model
    }

    private static func entity(name: String, className: String,
                               attributes: [NSAttributeDescription]) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = className
        entity.properties = attributes
        return entity
    }

    private static func attr(_ name: String, _ type: NSAttributeType,
                             optional: Bool = false,
                             allowsExternalStorage: Bool = false) -> NSAttributeDescription {
        let a = NSAttributeDescription()
        a.name = name
        a.attributeType = type
        a.isOptional = optional
        a.allowsExternalBinaryDataStorage = allowsExternalStorage
        return a
    }
}
