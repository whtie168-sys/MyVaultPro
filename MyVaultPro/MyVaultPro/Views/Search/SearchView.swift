//
//  SearchView.swift
//  MyVaultPro
//
//  Global search across all modules with real-time filtering.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var focused: Bool

    private var results: [SearchResult] { viewModel.results(from: store) }

    var body: some View {
        ZStack {
            VaultBackground()
            VStack(spacing: Theme.Spacing.md) {
                searchField
                if viewModel.query.isEmpty {
                    suggestions
                } else if results.isEmpty {
                    EmptyStateView(icon: "magnifyingglass",
                                   title: "No Results",
                                   message: "No items match \"\(viewModel.query)\". Try a different search.")
                } else {
                    resultsList
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.sm)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .onAppear { focused = true }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            TextField("Search your vault…", text: $viewModel.query)
                .font(.vaultBody)
                .foregroundStyle(Theme.textPrimary)
                .focused($focused)
                .autocorrectionDisabled()
            if !viewModel.query.isEmpty {
                Button { viewModel.query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Search across assets, collections, documents, subscriptions, and maintenance.")
                .font(.vaultBody)
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, Theme.Spacing.sm)
            HStack(spacing: Theme.Spacing.sm) {
                miniStat("\(store.totalAssets)", "Assets", Theme.indigo)
                miniStat("\(store.totalCollections)", "Items", Theme.teal)
                miniStat("\(store.totalDocuments)", "Docs", Theme.blue)
            }
        }
    }

    private func miniStat(_ value: String, _ label: String, _ tint: Color) -> some View {
        VaultCard {
            VStack(spacing: 4) {
                Text(value).font(.vaultTitle2).foregroundStyle(tint)
                Text(label).font(.vaultCaption).foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.sm) {
                ForEach(results) { result in
                    HStack(spacing: 14) {
                        IconBadge(icon: result.icon, tint: result.tint, size: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(result.title)
                                .font(.vaultHeadline)
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text(result.subtitle)
                                .font(.vaultCaption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        StatusBadge(text: result.module.rawValue, tint: result.tint)
                    }
                    .padding(Theme.Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).strokeBorder(Theme.stroke, lineWidth: 1))
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
    }
}
