//
//  SubscriptionListView.swift
//  MyVaultPro
//

import SwiftUI

struct SubscriptionListView: View {
    @EnvironmentObject private var store: DataStore
    @FetchRequest(fetchRequest: SubscriptionItem.fetchAll()) private var subscriptions: FetchedResults<SubscriptionItem>

    @State private var showAdd = false

    private var activeSubs: [SubscriptionItem] { subscriptions.filter(\.isActive) }
    private var monthlyTotal: Double { activeSubs.reduce(0) { $0 + $1.monthlyCost } }
    private var yearlyTotal: Double { monthlyTotal * 12 }

    var body: some View {
        ZStack {
            VaultBackground()
            if subscriptions.isEmpty {
                EmptyStateView(icon: "arrow.triangle.2.circlepath",
                               title: "No Subscriptions Yet",
                               message: "Track Netflix, Spotify, cloud storage, and more. Never miss a renewal again.",
                               actionTitle: "Add Subscription") { showAdd = true }
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        spendCard
                        LazyVStack(spacing: Theme.Spacing.sm) {
                            ForEach(subscriptions) { sub in
                                NavigationLink {
                                    SubscriptionDetailView(subscription: sub)
                                } label: {
                                    SubscriptionRow(subscription: sub)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
        }
        .navigationTitle("Subscriptions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showAdd) { SubscriptionEditView(subscription: nil) }
    }

    private var spendCard: some View {
        VaultCard(elevated: true) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Spend")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Format.moneyPrecise(monthlyTotal))
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(Format.money(yearlyTotal)) / year")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.pink)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(activeSubs.count)")
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.pink)
                    Text("active")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Row

struct SubscriptionRow: View {
    @ObservedObject var subscription: SubscriptionItem

    private var renewalInfo: (text: String, tint: Color)? {
        guard let date = subscription.renewalDate, subscription.isActive else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return ("Overdue", Theme.orange) }
        if days <= 7 { return (Format.relativeDays(days), Theme.amber) }
        return (Format.relativeDays(days), Theme.textSecondary)
    }

    var body: some View {
        VaultCard(padding: Theme.Spacing.sm) {
            HStack(spacing: 14) {
                IconBadge(icon: subscription.categoryEnum.icon, tint: subscription.categoryEnum.tint, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.serviceName)
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text("\(Format.moneyPrecise(subscription.cost)) · \(subscription.billingCycle)")
                            .font(.vaultCaption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    if !subscription.isActive {
                        StatusBadge(text: "Paused", tint: Theme.slate)
                    } else if let info = renewalInfo {
                        StatusBadge(text: info.text, tint: info.tint)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
    }
}
