//
//  MaintenanceDetailView.swift
//  MyVaultPro
//

import SwiftUI

struct MaintenanceDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var record: MaintenanceRecord

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
                    if let notes = record.notes, !notes.isEmpty {
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
        .navigationTitle(record.itemName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showEdit = true } } }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showEdit) { MaintenanceEditView(record: record) }
        .confirmationDialog("Delete this record?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(record); dismiss() }
        }
    }

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                .fill(Theme.tintGradient(record.typeEnum.tint))
                .frame(height: 150)
            VStack(spacing: 10) {
                Image(systemName: record.typeEnum.icon)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
                Text(record.type)
                    .font(.vaultCallout)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: Theme.Spacing.sm) {
            StatCard(title: "Cost", value: Format.money(record.cost),
                     icon: "dollarsign.circle.fill", tint: Theme.orange)
            StatCard(title: "Type", value: record.type,
                     icon: record.typeEnum.icon, tint: record.typeEnum.tint)
        }
    }

    private var detailsSection: some View {
        VaultCard {
            VStack(spacing: 2) {
                DetailRow(label: "Service Date", value: Format.date(record.maintenanceDate), icon: "calendar", tint: Theme.blue)
                if let next = record.nextDueDate {
                    Divider().overlay(Theme.stroke)
                    let days = Calendar.current.dateComponents([.day], from: Date(), to: next).day ?? 0
                    DetailRow(label: "Next Due",
                              value: "\(Format.date(next)) · \(Format.relativeDays(days))",
                              icon: "bell.fill", tint: days <= 14 ? Theme.amber : Theme.green)
                }
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            HStack { Image(systemName: "trash.fill"); Text("Delete Record") }
                .font(.vaultCallout).foregroundStyle(Theme.orange)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.orange.opacity(0.12)))
        }
        .padding(.top, Theme.Spacing.sm)
    }
}
