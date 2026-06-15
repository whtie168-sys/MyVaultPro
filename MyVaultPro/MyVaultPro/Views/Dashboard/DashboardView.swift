//
//  DashboardView.swift
//  MyVaultPro
//
//  The premium home screen: hero overview, quick actions, recent
//  activity, upcoming events, and mini statistics.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: DataStore
    @State private var showSearch = false
    @State private var activeSheet: QuickAddSheet?

    @State private var showBlackCover = true
    
    var body: some View {
        
        NavigationStack {
            ZStack {

                VaultBackground()

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        heroCard
                        quickActions
                        upcomingSection
                        recentSection
                        miniStats
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }

                if showBlackCover {
                    Color.black
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(9999)
                }
            }
            
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSearch = true } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .navigationDestination(isPresented: $showSearch) { SearchView() }
            .onAppear {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                    withAnimation(.easeOut(duration: 0.3)) {
                        showBlackCover = false
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .asset: AssetEditView(asset: nil)
                case .document: DocumentEditView(document: nil)
                case .subscription: SubscriptionEditView(subscription: nil)
                case .collection: CollectionEditView(item: nil)
                }
            }
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Portfolio Value")
                        .font(.vaultCallout)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(Format.money(store.totalPortfolioValue))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }

            HStack(spacing: 0) {
                heroStat(value: "\(store.totalAssets)", label: "Assets")
                heroDivider
                heroStat(value: "\(store.totalCollections)", label: "Collectibles")
                heroDivider
                heroStat(value: "\(store.totalDocuments)", label: "Documents")
                heroDivider
                heroStat(value: "\(store.activeSubscriptions)", label: "Subs")
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(Theme.heroGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Theme.indigo.opacity(0.35), radius: 24, y: 12)
    }

    private func heroStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
    }

    private var heroDivider: some View {
        Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 32)
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Quick Actions")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                quickAction("Add Asset", "shippingbox.fill", Theme.indigo) { activeSheet = .asset }
                quickAction("Add Document", "doc.text.fill", Theme.blue) { activeSheet = .document }
                quickAction("Add Subscription", "arrow.triangle.2.circlepath", Theme.pink) { activeSheet = .subscription }
                quickAction("Add Collection", "square.stack.3d.up.fill", Theme.teal) { activeSheet = .collection }
            }
        }
    }

    private func quickAction(_ title: String, _ icon: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(icon: icon, tint: tint, size: 40)
                Text(title)
                    .font(.vaultCallout)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
        }
    }

    // MARK: - Upcoming

    private var upcomingSection: some View {
        let events = Array(store.upcomingEvents(within: 60).prefix(4))
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Upcoming")
            if events.isEmpty {
                VaultCard {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.green)
                        Text("Nothing expiring soon. You're all set.")
                            .font(.vaultBody)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                    }
                }
            } else {
                VaultCard(padding: Theme.Spacing.sm) {
                    VStack(spacing: 0) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            UpcomingRow(event: event)
                            if index < events.count - 1 {
                                Divider().overlay(Theme.stroke).padding(.leading, 54)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent activity

    private var recentSection: some View {
        let recent = Array(store.recentlyAdded.prefix(4))
        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Recently Added")
            if recent.isEmpty {
                VaultCard { Text("No records yet.").font(.vaultBody).foregroundStyle(Theme.textSecondary) }
            } else {
                VaultCard(padding: Theme.Spacing.sm) {
                    VStack(spacing: 0) {
                        ForEach(Array(recent.enumerated()), id: \.element.id) { index, item in
                            HStack(spacing: 12) {
                                IconBadge(icon: item.icon, tint: item.tint, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.vaultCallout)
                                        .foregroundStyle(Theme.textPrimary)
                                        .lineLimit(1)
                                    Text(item.subtitle)
                                        .font(.vaultCaption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                Text(item.date, format: .dateTime.month().day())
                                    .font(.vaultCaption)
                                    .foregroundStyle(Theme.textTertiary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            if index < recent.count - 1 {
                                Divider().overlay(Theme.stroke).padding(.leading, 54)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mini stats

    private var miniStats: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "At a Glance")
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(title: "Monthly Subs", value: Format.money(store.monthlySubscriptionCost),
                         icon: "creditcard.fill", tint: Theme.pink)
                StatCard(title: "Asset Value", value: Format.money(store.totalAssetValue),
                         icon: "chart.line.uptrend.xyaxis", tint: Theme.green)
            }
            HStack(spacing: Theme.Spacing.sm) {
                StatCard(title: "Collection Value", value: Format.money(store.totalCollectionValue),
                         icon: "sparkles", tint: Theme.amber)
                StatCard(title: "Maintenance / yr", value: Format.money(store.yearlyMaintenanceCost),
                         icon: "wrench.fill", tint: Theme.orange)
            }
        }
    }
}

// MARK: - Upcoming row

struct UpcomingRow: View {
    let event: UpcomingEvent

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(icon: event.kind.icon, tint: event.kind.tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.vaultCallout)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(event.kind.label)
                    .font(.vaultCaption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Format.relativeDays(event.daysRemaining))
                    .font(.vaultCaption)
                    .foregroundStyle(event.daysRemaining <= 14 ? Theme.orange : Theme.textSecondary)
                Text(Format.date(event.date))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Quick add sheet routing

enum QuickAddSheet: Identifiable {
    case asset, document, subscription, collection
    var id: Int { hashValue }
}
