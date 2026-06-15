//
//  CollectionDetailView.swift
//  MyVaultPro
//

import SwiftUI

struct CollectionDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var item: CollectionItem

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    heroSection
                    statsSection
                    detailsSection
                    if let notes = item.notes, !notes.isEmpty {
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
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showEdit = true } }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showEdit) { CollectionEditView(item: item) }
        .confirmationDialog("Delete this item?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(item); dismiss() }
        }
    }

    private var heroSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if let data = item.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(height: 240).frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .fill(Theme.tintGradient(item.categoryEnum.tint))
                        .frame(height: 200)
                    Image(systemName: item.categoryEnum.icon)
                        .font(.system(size: 64, weight: .semibold)).foregroundStyle(.white)
                }
            }
            HStack {
                Chip(title: item.category, icon: item.categoryEnum.icon, tint: item.categoryEnum.tint, selected: true)
                StatusBadge(text: item.condition, tint: item.conditionEnum.tint)
                Spacer()
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: Theme.Spacing.sm) {
            StatCard(title: "Estimated Value", value: Format.money(item.estimatedValue),
                     icon: "sparkles", tint: Theme.amber)
            StatCard(title: "Condition", value: item.condition,
                     icon: "star.fill", tint: item.conditionEnum.tint)
        }
    }

    private var detailsSection: some View {
        VaultCard {
            VStack(spacing: 2) {
                DetailRow(label: "Category", value: item.category, icon: item.categoryEnum.icon, tint: item.categoryEnum.tint)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Acquired", value: Format.date(item.purchaseDate), icon: "calendar", tint: Theme.blue)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Added", value: Format.date(item.createdAt), icon: "clock.fill", tint: Theme.slate)
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            HStack { Image(systemName: "trash.fill"); Text("Delete Item") }
                .font(.vaultCallout).foregroundStyle(Theme.orange)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.orange.opacity(0.12)))
        }
        .padding(.top, Theme.Spacing.sm)
    }
}
