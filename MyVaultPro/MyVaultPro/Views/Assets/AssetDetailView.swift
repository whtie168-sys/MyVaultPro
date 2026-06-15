//
//  AssetDetailView.swift
//  MyVaultPro
//
//  Rich asset detail with hero photo, value, warranty, and metadata.
//

import SwiftUI

struct AssetDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var asset: Asset

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    heroSection
                    valueSection
                    detailsSection
                    if let notes = asset.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                    deleteButton
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle(asset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
                    .font(.vaultCallout)
            }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showEdit) { AssetEditView(asset: asset) }
        .confirmationDialog("Delete this asset?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(asset)
                dismiss()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if let data = asset.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .fill(Theme.tintGradient(asset.categoryEnum.tint))
                        .frame(height: 180)
                    Image(systemName: asset.categoryEnum.icon)
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            HStack {
                Chip(title: asset.category, icon: asset.categoryEnum.icon, tint: asset.categoryEnum.tint, selected: true)
                Spacer()
            }
        }
    }

    private var valueSection: some View {
        HStack(spacing: Theme.Spacing.sm) {
            StatCard(title: "Current Value", value: Format.money(asset.currentValue),
                     icon: "chart.line.uptrend.xyaxis", tint: Theme.green)
            StatCard(title: "Purchase Price", value: Format.money(asset.purchasePrice),
                     icon: "tag.fill", tint: Theme.indigo)
        }
    }

    private var detailsSection: some View {
        VaultCard {
            VStack(spacing: 2) {
                DetailRow(label: "Purchase Date", value: Format.date(asset.purchaseDate),
                          icon: "calendar", tint: Theme.blue)
                Divider().overlay(Theme.stroke)
                if let serial = asset.serialNumber, !serial.isEmpty {
                    DetailRow(label: "Serial Number", value: serial, icon: "number", tint: Theme.slate)
                    Divider().overlay(Theme.stroke)
                }
                DetailRow(label: "Warranty",
                          value: asset.warrantyExpiration != nil ? Format.date(asset.warrantyExpiration) : "None",
                          icon: "checkmark.seal.fill", tint: Theme.green)
                if let w = asset.warrantyExpiration {
                    Divider().overlay(Theme.stroke)
                    let days = Calendar.current.dateComponents([.day], from: Date(), to: w).day ?? 0
                    DetailRow(label: "Warranty Status",
                              value: days >= 0 ? "Active · \(Format.relativeDays(days))" : "Expired",
                              icon: "clock.fill", tint: days >= 0 ? Theme.green : Theme.orange)
                }
            }
        }
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Notes")
            VaultCard {
                Text(notes)
                    .font(.vaultBody)
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete Asset")
            }
            .font(.vaultCallout)
            .foregroundStyle(Theme.orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Theme.orange.opacity(0.12)))
        }
        .padding(.top, Theme.Spacing.sm)
    }
}
