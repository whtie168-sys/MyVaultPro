//
//  RecordsHubView.swift
//  MyVaultPro
//
//  "Records" tab — a hub linking to Documents, Subscriptions,
//  Maintenance, and the Statistics dashboard.
//

import SwiftUI

struct RecordsHubView: View {
    @EnvironmentObject private var store: DataStore

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        statsBanner
                        VStack(spacing: Theme.Spacing.sm) {
                            NavigationLink { DocumentListView() } label: {
                                hubRow("Documents", "Passports, insurance, warranties",
                                       "doc.text.fill", Theme.blue, count: store.totalDocuments)
                            }.buttonStyle(.plain)
                            NavigationLink { SubscriptionListView() } label: {
                                hubRow("Subscriptions", "Track recurring spend & renewals",
                                       "arrow.triangle.2.circlepath", Theme.pink, count: store.activeSubscriptions)
                            }.buttonStyle(.plain)
                            NavigationLink { MaintenanceListView() } label: {
                                hubRow("Maintenance", "Service history & due dates",
                                       "wrench.and.screwdriver.fill", Theme.orange, count: store.maintenance.count)
                            }.buttonStyle(.plain)
                            NavigationLink { StatisticsView() } label: {
                                hubRow("Statistics", "Charts & insights across your vault",
                                       "chart.bar.xaxis", Theme.teal, count: nil)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Records")
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
    }

    private var statsBanner: some View {
        VaultCard(elevated: true) {
            VStack(alignment: .leading, spacing: 14) {
                Text("This Month")
                    .font(.vaultCallout)
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: Theme.Spacing.md) {
                    bannerStat(Format.money(store.monthlySubscriptionCost), "Subscriptions", Theme.pink)
                    Divider().overlay(Theme.stroke).frame(height: 40)
                    bannerStat(Format.money(store.yearlyMaintenanceCost), "Maint. / yr", Theme.orange)
                    Divider().overlay(Theme.stroke).frame(height: 40)
                    bannerStat("\(store.upcomingEvents(within: 30).count)", "Due soon", Theme.amber)
                }
            }
        }
    }

    private func bannerStat(_ value: String, _ label: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.vaultHeadline)
                .foregroundStyle(tint)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func hubRow(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, count: Int?) -> some View {
        VaultCard {
            HStack(spacing: 14) {
                IconBadge(icon: icon, tint: tint, size: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.vaultHeadline).foregroundStyle(Theme.textPrimary)
                    Text(subtitle).font(.vaultCaption).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                if let count {
                    Text("\(count)")
                        .font(.vaultHeadline)
                        .foregroundStyle(tint)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill(tint.opacity(0.15)))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }
}
