//
//  CollectionListView.swift
//  MyVaultPro
//
//  Collections grid with category filtering and value summary.
//

import SwiftUI

struct CollectionListView: View {
    @EnvironmentObject private var store: DataStore
    @FetchRequest(fetchRequest: CollectionItem.fetchAll()) private var items: FetchedResults<CollectionItem>

    @State private var selectedCategory: CollectionCategory?
    @State private var showAdd = false

    private var filtered: [CollectionItem] {
        guard let selectedCategory else { return Array(items) }
        return items.filter { $0.categoryEnum == selectedCategory }
    }

    private let columns = [GridItem(.flexible(), spacing: Theme.Spacing.sm),
                           GridItem(.flexible(), spacing: Theme.Spacing.sm)]

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                if items.isEmpty {
                    EmptyStateView(icon: "square.stack.3d.up.fill",
                                   title: "No Collectibles Yet",
                                   message: "Catalog your cards, coins, watches, and more with photos and estimated values.",
                                   actionTitle: "Add Item") { showAdd = true }
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            summaryCard
                            filterChips
                            LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                                ForEach(filtered) { item in
                                    NavigationLink {
                                        CollectionDetailView(item: item)
                                    } label: {
                                        CollectionCardCell(item: item)
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
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .sheet(isPresented: $showAdd) { CollectionEditView(item: nil) }
        }
    }

    private var summaryCard: some View {
        VaultCard(elevated: true) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Collection Value")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Format.money(store.totalCollectionValue))
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(items.count)")
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.amber)
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
                ForEach(CollectionCategory.allCases) { category in
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

// MARK: - Grid cell

struct CollectionCardCell: View {
    @ObservedObject var item: CollectionItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let data = item.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 130)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    ZStack {
                        Theme.tintGradient(item.categoryEnum.tint)
                        Image(systemName: item.categoryEnum.icon)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 130)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.vaultCallout)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                HStack {
                    Text(Format.money(item.estimatedValue))
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.amber)
                    Spacer()
                    Text(item.condition)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(item.conditionEnum.tint)
                }
            }
            .padding(10)
        }
        .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
    }
}
