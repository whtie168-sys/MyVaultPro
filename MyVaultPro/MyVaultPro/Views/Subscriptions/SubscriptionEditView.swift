//
//  SubscriptionEditView.swift
//  MyVaultPro
//

import SwiftUI
import CoreData

struct SubscriptionEditView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let subscription: SubscriptionItem?

    @State private var serviceName = ""
    @State private var cost: Double = 0
    @State private var billingCycle: BillingCycle = .monthly
    @State private var category: SubscriptionCategory = .entertainment
    @State private var notes = ""
    @State private var isActive = true
    @State private var renewalDate = Date()
    @State private var hasRenewal = true

    private var isEditing: Bool { subscription != nil }
    private var canSave: Bool { !serviceName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        FormSection(title: "Service") {
                            VaultTextField(title: "Service Name", text: $serviceName, placeholder: "e.g. Netflix")
                            CategoryChipPicker(title: "Category", options: SubscriptionCategory.allCases,
                                               selection: $category, label: { $0.rawValue },
                                               icon: { $0.icon }, tint: { $0.tint })
                        }
                        FormSection(title: "Billing") {
                            VaultNumberField(title: "Cost", value: $cost)
                            CategoryChipPicker(title: "Billing Cycle", options: BillingCycle.allCases,
                                               selection: $billingCycle, label: { $0.rawValue },
                                               icon: { _ in "repeat" }, tint: { _ in Theme.pink })
                            VaultDateField(title: "Renewal Date", date: $renewalDate, isEnabled: $hasRenewal)
                        }
                        FormSection(title: "Status") {
                            Toggle(isOn: $isActive) {
                                Text("Active").font(.vaultBody).foregroundStyle(Theme.textPrimary)
                            }.tint(Theme.accent)
                        }
                        FormSection(title: "Notes") {
                            VaultNotesField(title: "Notes", text: $notes)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "New Subscription")
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
        guard let subscription else { return }
        serviceName = subscription.serviceName
        cost = subscription.cost
        billingCycle = subscription.billingCycleEnum
        category = subscription.categoryEnum
        notes = subscription.notes ?? ""
        isActive = subscription.isActive
        if let r = subscription.renewalDate { renewalDate = r; hasRenewal = true } else { hasRenewal = false }
    }

    private func save() {
        let target = subscription ?? SubscriptionItem(context: store.context)
        if subscription == nil {
            target.id = UUID()
            target.createdAt = Date()
        }
        target.serviceName = serviceName.trimmingCharacters(in: .whitespaces)
        target.cost = cost
        target.billingCycle = billingCycle.rawValue
        target.category = category.rawValue
        target.notes = notes.isEmpty ? nil : notes
        target.isActive = isActive
        target.renewalDate = hasRenewal ? renewalDate : nil
        target.updatedAt = Date()
        store.saveAndRefresh()
        dismiss()
    }
}
