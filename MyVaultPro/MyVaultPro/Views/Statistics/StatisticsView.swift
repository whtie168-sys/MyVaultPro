//
//  StatisticsView.swift
//  MyVaultPro
//
//  Statistics dashboard: distributions, growth, costs, and activity.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: DataStore

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    summaryGrid
                    assetDistribution
                    collectionDistribution
                    subscriptionCost
                    monthlyActivity
                    documentMaintenance
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
    }

    // MARK: - Summary

    private var summaryGrid: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(title: "Portfolio Value", value: Format.money(store.totalPortfolioValue),
                         icon: "chart.pie.fill", tint: Theme.indigo)
                StatCard(title: "Documents", value: "\(store.totalDocuments)",
                         icon: "doc.text.fill", tint: Theme.blue)
            }
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(title: "Monthly Subs", value: Format.money(store.monthlySubscriptionCost),
                         icon: "creditcard.fill", tint: Theme.pink)
                StatCard(title: "Maintenance/yr", value: Format.money(store.yearlyMaintenanceCost),
                         icon: "wrench.fill", tint: Theme.orange)
            }
        }
    }

    // MARK: - Asset distribution (bar)

    private var assetDistribution: some View {
        let data = store.assetCategoryDistribution()
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Asset Distribution")
            VaultCard {
                if data.isEmpty {
                    chartEmpty("No assets to chart yet")
                } else {
                    BarChartView(data: data, valueFormatter: { "\(Int($0))" })
                }
            }
        }
    }

    // MARK: - Collection distribution (donut)

    private var collectionDistribution: some View {
        let segments = store.collectionValueByCategory()
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Collection Value")
            VaultCard {
                if segments.isEmpty {
                    chartEmpty("No collectibles to chart yet")
                } else {
                    HStack(spacing: Theme.Spacing.lg) {
                        DonutChartView(segments: segments)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(segments) { segment in
                                HStack(spacing: 8) {
                                    Circle().fill(segment.tint).frame(width: 10, height: 10)
                                    Text(segment.label)
                                        .font(.vaultCaption)
                                        .foregroundStyle(Theme.textSecondary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(Format.money(segment.value))
                                        .font(.vaultCaption)
                                        .foregroundStyle(Theme.textPrimary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subscription cost by category (bar)

    private var subscriptionCost: some View {
        let data = store.subscriptionCostByCategory()
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Subscription Cost")
            VaultCard {
                if data.isEmpty {
                    chartEmpty("No subscriptions to chart yet")
                } else {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Monthly cost by category")
                            .font(.vaultCaption)
                            .foregroundStyle(Theme.textTertiary)
                        BarChartView(data: data, valueFormatter: { "$\(Int($0))" })
                    }
                }
            }
        }
    }

    // MARK: - Monthly activity (line)

    private var monthlyActivity: some View {
        let data = store.monthlyActivity()
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Monthly Activity")
            VaultCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Records added over the last 6 months")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textTertiary)
                    LineChartView(data: data, tint: Theme.teal)
                }
            }
        }
    }

    // MARK: - Document / maintenance progress

    private var documentMaintenance: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Coverage")
            let total = max(store.totalAssets, 1)
            let withWarranty = store.assets.filter { $0.warrantyExpiration != nil }.count
            let activeSubs = store.activeSubscriptions
            let totalSubs = max(store.subscriptions.count, 1)
            ProgressCard(title: "Assets with Warranty",
                         value: "\(withWarranty)/\(store.totalAssets)",
                         progress: Double(withWarranty) / Double(total),
                         tint: Theme.green,
                         caption: "Tracked warranty coverage")
            ProgressCard(title: "Active Subscriptions",
                         value: "\(activeSubs)/\(store.subscriptions.count)",
                         progress: Double(activeSubs) / Double(totalSubs),
                         tint: Theme.pink,
                         caption: "Currently active vs. total")
        }
    }

    private func chartEmpty(_ text: String) -> some View {
        Text(text)
            .font(.vaultBody)
            .foregroundStyle(Theme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 120)
    }
}
