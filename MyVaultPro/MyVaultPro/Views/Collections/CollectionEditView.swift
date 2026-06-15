//
//  CollectionEditView.swift
//  MyVaultPro
//

import SwiftUI
import CoreData

struct CollectionEditView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let item: CollectionItem?

    @State private var name = ""
    @State private var category: CollectionCategory = .tradingCards
    @State private var estimatedValue: Double = 0
    @State private var condition: ItemCondition = .excellent
    @State private var notes = ""
    @State private var photoData: Data?
    @State private var purchaseDate = Date()
    @State private var hasPurchaseDate = false

    private var isEditing: Bool { item != nil }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        FormSection(title: "Details") {
                            VaultTextField(title: "Name", text: $name, placeholder: "e.g. Charizard 1st Edition")
                            CategoryChipPicker(title: "Category", options: CollectionCategory.allCases,
                                               selection: $category, label: { $0.rawValue },
                                               icon: { $0.icon }, tint: { $0.tint })
                            VaultPhotoPicker(imageData: $photoData)
                        }
                        FormSection(title: "Value & Condition") {
                            VaultNumberField(title: "Estimated Value", value: $estimatedValue)
                            CategoryChipPicker(title: "Condition", options: ItemCondition.allCases,
                                               selection: $condition, label: { $0.rawValue },
                                               icon: { _ in "star.fill" }, tint: { $0.tint })
                        }
                        FormSection(title: "Acquisition") {
                            VaultDateField(title: "Purchase Date", date: $purchaseDate, isEnabled: $hasPurchaseDate)
                        }
                        FormSection(title: "Notes") {
                            VaultNotesField(title: "Notes", text: $notes)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
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
        guard let item else { return }
        name = item.name
        category = item.categoryEnum
        estimatedValue = item.estimatedValue
        condition = item.conditionEnum
        notes = item.notes ?? ""
        photoData = item.photo
        if let d = item.purchaseDate { purchaseDate = d; hasPurchaseDate = true }
    }

    private func save() {
        let target = item ?? CollectionItem(context: store.context)
        if item == nil {
            target.id = UUID()
            target.createdAt = Date()
        }
        target.name = name.trimmingCharacters(in: .whitespaces)
        target.category = category.rawValue
        target.estimatedValue = estimatedValue
        target.condition = condition.rawValue
        target.notes = notes.isEmpty ? nil : notes
        target.photo = photoData
        target.purchaseDate = hasPurchaseDate ? purchaseDate : nil
        target.updatedAt = Date()
        store.saveAndRefresh()
        dismiss()
    }
}
