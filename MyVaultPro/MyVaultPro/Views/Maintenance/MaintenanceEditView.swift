//
//  MaintenanceEditView.swift
//  MyVaultPro
//

import SwiftUI
import CoreData

struct MaintenanceEditView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let record: MaintenanceRecord?

    @State private var itemName = ""
    @State private var type: MaintenanceType = .service
    @State private var cost: Double = 0
    @State private var notes = ""
    @State private var maintenanceDate = Date()
    @State private var hasMaintenanceDate = true
    @State private var nextDueDate = Date()
    @State private var hasNextDue = false

    private var isEditing: Bool { record != nil }
    private var canSave: Bool { !itemName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        FormSection(title: "Record") {
                            VaultTextField(title: "Item Name", text: $itemName, placeholder: "e.g. Tesla Model 3")
                            CategoryChipPicker(title: "Type", options: MaintenanceType.allCases,
                                               selection: $type, label: { $0.rawValue },
                                               icon: { $0.icon }, tint: { $0.tint })
                            VaultNumberField(title: "Cost", value: $cost)
                        }
                        FormSection(title: "Dates") {
                            VaultDateField(title: "Service Date", date: $maintenanceDate, isEnabled: $hasMaintenanceDate)
                            VaultDateField(title: "Next Due Date", date: $nextDueDate, isEnabled: $hasNextDue)
                        }
                        FormSection(title: "Notes") {
                            VaultNotesField(title: "Notes", text: $notes)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle(isEditing ? "Edit Record" : "New Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.fontWeight(.semibold).disabled(!canSave)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let record else { return }
        itemName = record.itemName
        type = record.typeEnum
        cost = record.cost
        notes = record.notes ?? ""
        if let d = record.maintenanceDate { maintenanceDate = d; hasMaintenanceDate = true } else { hasMaintenanceDate = false }
        if let n = record.nextDueDate { nextDueDate = n; hasNextDue = true }
    }

    private func save() {
        let target = record ?? MaintenanceRecord(context: store.context)
        if record == nil {
            target.id = UUID()
            target.createdAt = Date()
        }
        target.itemName = itemName.trimmingCharacters(in: .whitespaces)
        target.type = type.rawValue
        target.cost = cost
        target.notes = notes.isEmpty ? nil : notes
        target.maintenanceDate = hasMaintenanceDate ? maintenanceDate : nil
        target.nextDueDate = hasNextDue ? nextDueDate : nil
        target.updatedAt = Date()
        store.saveAndRefresh()
        dismiss()
    }
}
