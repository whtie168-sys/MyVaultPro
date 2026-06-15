//
//  SubscriptionDetailView.swift
//  MyVaultPro
//

import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var subscription: SubscriptionItem

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    header
                    statsSection
                    detailsSection
                    pauseButton
                    if let notes = subscription.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            SectionHeader(title: "Notes")
                            VaultCard {
                                Text(notes).font(.vaultBody).foregroundStyle(Theme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    deleteButton
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle(subscription.serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showEdit = true } } }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showEdit) { SubscriptionEditView(subscription: subscription) }
        .confirmationDialog("Delete this subscription?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(subscription); dismiss() }
        }
    }

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(Theme.tintGradient(subscription.categoryEnum.tint))
                .frame(height: 150)
            VStack(spacing: 10) {
                Image(systemName: subscription.categoryEnum.icon)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subscription.category)
                    .font(.vaultCallout)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: Theme.Spacing.sm) {
            StatCard(title: subscription.billingCycle, value: Format.moneyPrecise(subscription.cost),
                     icon: "creditcard.fill", tint: Theme.pink)
            StatCard(title: "Per Month", value: Format.moneyPrecise(subscription.monthlyCost),
                     icon: "calendar", tint: Theme.indigo)
        }
    }

    private var detailsSection: some View {
        VaultCard {
            VStack(spacing: 2) {
                DetailRow(label: "Category", value: subscription.category,
                          icon: subscription.categoryEnum.icon, tint: subscription.categoryEnum.tint)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Billing Cycle", value: subscription.billingCycle, icon: "repeat", tint: Theme.blue)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Next Renewal", value: Format.date(subscription.renewalDate),
                          icon: "arrow.triangle.2.circlepath", tint: Theme.pink)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Status", value: subscription.isActive ? "Active" : "Paused",
                          icon: "circle.fill", tint: subscription.isActive ? Theme.green : Theme.slate)
            }
        }
    }

    private var pauseButton: some View {
        Button {
            subscription.isActive.toggle()
            subscription.updatedAt = Date()
            store.saveAndRefresh()
        } label: {
            HStack {
                Image(systemName: subscription.isActive ? "pause.circle.fill" : "play.circle.fill")
                Text(subscription.isActive ? "Pause Subscription" : "Resume Subscription")
            }
            .font(.vaultCallout)
            .foregroundStyle(subscription.isActive ? Theme.amber : Theme.green)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill((subscription.isActive ? Theme.amber : Theme.green).opacity(0.12)))
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            HStack { Image(systemName: "trash.fill"); Text("Delete Subscription") }
                .font(.vaultCallout).foregroundStyle(Theme.orange)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.orange.opacity(0.12)))
        }
    }
}
