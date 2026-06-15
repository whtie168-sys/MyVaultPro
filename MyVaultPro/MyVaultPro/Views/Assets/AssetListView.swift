//
//  AssetListView.swift
//  MyVaultPro
//
//  Premium asset list with category filter chips and value summary.
//

import SwiftUI

struct AssetListView: View {
    @EnvironmentObject private var store: DataStore
    @FetchRequest(fetchRequest: Asset.fetchAll()) private var assets: FetchedResults<Asset>

    @State private var selectedCategory: AssetCategory?
    @State private var showAdd = false

    private var filtered: [Asset] {
        guard let selectedCategory else { return Array(assets) }
        return assets.filter { $0.categoryEnum == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                if assets.isEmpty {
                    EmptyStateView(icon: "shippingbox.fill",
                                   title: "No Assets Yet",
                                   message: "Track your laptop, camera, car, and more. Add your first asset to get started.",
                                   actionTitle: "Add Asset") { showAdd = true }
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            summaryCard
                            filterChips
                            LazyVStack(spacing: Theme.Spacing.sm) {
                                ForEach(filtered) { asset in
                                    NavigationLink {
                                        AssetDetailView(asset: asset)
                                    } label: {
                                        AssetRow(asset: asset)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }
            }
            .navigationTitle("Assets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .sheet(isPresented: $showAdd) { AssetEditView(asset: nil) }
        }
    }

    private var summaryCard: some View {
        VaultCard(elevated: true) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Asset Value")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Format.money(store.totalAssetValue))
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(assets.count)")
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.accent)
                    Text("items")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button { selectedCategory = nil } label: {
                    Chip(title: "All", tint: Theme.slate, selected: selectedCategory == nil)
                }
                ForEach(AssetCategory.allCases) { category in
                    Button { selectedCategory = category } label: {
                        Chip(title: category.rawValue, icon: category.icon,
                             tint: category.tint, selected: selectedCategory == category)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - Asset row

struct AssetRow: View {
    @ObservedObject var asset: Asset

    var body: some View {
        VaultCard(padding: Theme.Spacing.sm) {
            HStack(spacing: 14) {
                PhotoThumbnail(data: asset.photo, fallbackIcon: asset.categoryEnum.icon, tint: asset.categoryEnum.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(asset.name)
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(asset.category)
                            .font(.vaultCaption)
                            .foregroundStyle(Theme.textSecondary)
                        if asset.hasWarranty {
                            StatusBadge(text: "Warranty", tint: Theme.green)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(Format.money(asset.currentValue))
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
    }
}
