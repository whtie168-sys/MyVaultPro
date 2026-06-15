//
//  AssetEditView.swift
//  MyVaultPro
//
//  Add / edit asset form. Passing nil creates a new asset.
//

import SwiftUI
import CoreData

struct AssetEditView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let asset: Asset?

    @State private var name = ""
    @State private var category: AssetCategory = .electronics
    @State private var purchasePrice: Double = 0
    @State private var currentValue: Double = 0
    @State private var serialNumber = ""
    @State private var notes = ""
    @State private var photoData: Data?

    @State private var purchaseDate = Date()
    @State private var hasPurchaseDate = false
    @State private var warrantyDate = Date()
    @State private var hasWarranty = false

    private var isEditing: Bool { asset != nil }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        FormSection(title: "Details") {
                            VaultTextField(title: "Name", text: $name, placeholder: "e.g. MacBook Pro")
                            CategoryChipPicker(title: "Category", options: AssetCategory.allCases,
                                               selection: $category, label: { $0.rawValue },
                                               icon: { $0.icon }, tint: { $0.tint })
                            VaultPhotoPicker(imageData: $photoData)
                        }
                        FormSection(title: "Value") {
                            VaultNumberField(title: "Purchase Price", value: $purchasePrice)
                            VaultNumberField(title: "Current Value", value: $currentValue)
                        }
                        FormSection(title: "Dates & Identification") {
                            VaultDateField(title: "Purchase Date", date: $purchaseDate, isEnabled: $hasPurchaseDate)
                            VaultDateField(title: "Warranty Expiration", date: $warrantyDate, isEnabled: $hasWarranty)
                            VaultTextField(title: "Serial Number", text: $serialNumber, placeholder: "Optional")
                        }
                        FormSection(title: "Notes") {
                            VaultNotesField(title: "Notes", text: $notes)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle(isEditing ? "Edit Asset" : "New Asset")
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
        guard let asset else { return }
        name = asset.name
        category = asset.categoryEnum
        purchasePrice = asset.purchasePrice
        currentValue = asset.currentValue
        serialNumber = asset.serialNumber ?? ""
        notes = asset.notes ?? ""
        photoData = asset.photo
        if let d = asset.purchaseDate { purchaseDate = d; hasPurchaseDate = true }
        if let w = asset.warrantyExpiration { warrantyDate = w; hasWarranty = true }
    }

    private func save() {
        let target = asset ?? Asset(context: store.context)
        if asset == nil {
            target.id = UUID()
            target.createdAt = Date()
        }
        target.name = name.trimmingCharacters(in: .whitespaces)
        target.category = category.rawValue
        target.purchasePrice = purchasePrice
        target.currentValue = currentValue
        target.serialNumber = serialNumber.isEmpty ? nil : serialNumber
        target.notes = notes.isEmpty ? nil : notes
        target.photo = photoData
        target.purchaseDate = hasPurchaseDate ? purchaseDate : nil
        target.warrantyExpiration = hasWarranty ? warrantyDate : nil
        target.updatedAt = Date()
        store.saveAndRefresh()
        dismiss()
    }
}
