//
//  MaintenanceListView.swift
//  MyVaultPro
//

import SwiftUI

struct MaintenanceListView: View {
    @EnvironmentObject private var store: DataStore
    @FetchRequest(fetchRequest: MaintenanceRecord.fetchAll()) private var records: FetchedResults<MaintenanceRecord>

    @State private var showAdd = false

    private var totalCost: Double { records.reduce(0) { $0 + $1.cost } }
    private var upcomingDue: [MaintenanceRecord] {
        records.filter { ($0.nextDueDate ?? .distantPast) >= Calendar.current.startOfDay(for: Date()) }
            .sorted { ($0.nextDueDate ?? .distantFuture) < ($1.nextDueDate ?? .distantFuture) }
    }

    var body: some View {
        ZStack {
            VaultBackground()
            if records.isEmpty {
                EmptyStateView(icon: "wrench.and.screwdriver.fill",
                               title: "No Records Yet",
                               message: "Log service, repairs, and inspections with costs and next-due reminders.",
                               actionTitle: "Add Record") { showAdd = true }
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        summaryCard
                        if !upcomingDue.isEmpty { dueSection }
                        SectionHeader(title: "History")
                        LazyVStack(spacing: Theme.Spacing.sm) {
                            ForEach(records) { record in
                                NavigationLink {
                                    MaintenanceDetailView(record: record)
                                } label: {
                                    MaintenanceRow(record: record)
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
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showAdd) { MaintenanceEditView(record: nil) }
    }

    private var summaryCard: some View {
        VaultCard(elevated: true) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Format.money(totalCost))
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(records.count)")
                        .font(.vaultTitle)
                        .foregroundStyle(Theme.orange)
                    Text("records")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var dueSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SectionHeader(title: "Coming Up")
            VaultCard(padding: Theme.Spacing.sm) {
                VStack(spacing: 0) {
                    ForEach(Array(upcomingDue.prefix(3).enumerated()), id: \.element.id) { index, record in
                        HStack(spacing: 12) {
                            IconBadge(icon: record.typeEnum.icon, tint: record.typeEnum.tint, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(record.itemName).font(.vaultCallout).foregroundStyle(Theme.textPrimary).lineLimit(1)
                                Text("Due \(Format.date(record.nextDueDate))").font(.vaultCaption).foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            if let due = record.nextDueDate {
                                let days = Calendar.current.dateComponents([.day], from: Date(), to: due).day ?? 0
                                StatusBadge(text: Format.relativeDays(days), tint: days <= 14 ? Theme.amber : Theme.textSecondary)
                            }
                        }
                        .padding(.vertical, 8).padding(.horizontal, 4)
                        if index < min(upcomingDue.count, 3) - 1 {
                            Divider().overlay(Theme.stroke).padding(.leading, 54)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Row

struct MaintenanceRow: View {
    @ObservedObject var record: MaintenanceRecord

    var body: some View {
        VaultCard(padding: Theme.Spacing.sm) {
            HStack(spacing: 14) {
                IconBadge(icon: record.typeEnum.icon, tint: record.typeEnum.tint, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.itemName)
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text("\(record.type) · \(Format.date(record.maintenanceDate))")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(Format.money(record.cost))
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
