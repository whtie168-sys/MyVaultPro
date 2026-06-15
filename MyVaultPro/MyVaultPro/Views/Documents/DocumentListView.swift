//
//  DocumentListView.swift
//  MyVaultPro
//

import SwiftUI

struct DocumentListView: View {
    @EnvironmentObject private var store: DataStore
    @FetchRequest(fetchRequest: DocumentRecord.fetchAll()) private var documents: FetchedResults<DocumentRecord>

    @State private var showAdd = false

    var body: some View {
        ZStack {
            VaultBackground()
            if documents.isEmpty {
                EmptyStateView(icon: "doc.text.fill",
                               title: "No Documents Yet",
                               message: "Keep passports, insurance, warranties, and certificates organized with expiration reminders.",
                               actionTitle: "Add Document") { showAdd = true }
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(documents) { document in
                            NavigationLink {
                                DocumentDetailView(document: document)
                            } label: {
                                DocumentRow(document: document)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showAdd) { DocumentEditView(document: nil) }
    }
}

// MARK: - Row

struct DocumentRow: View {
    @ObservedObject var document: DocumentRecord

    private var expiryInfo: (text: String, tint: Color)? {
        guard let exp = document.expirationDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: exp).day ?? 0
        if days < 0 { return ("Expired", Theme.orange) }
        if days <= 30 { return ("Expires \(Format.relativeDays(days))", Theme.amber) }
        return ("Valid", Theme.green)
    }

    var body: some View {
        VaultCard(padding: Theme.Spacing.sm) {
            HStack(spacing: 14) {
                IconBadge(icon: document.categoryEnum.icon, tint: document.categoryEnum.tint, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.title)
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text(document.category)
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    if let info = expiryInfo {
                        StatusBadge(text: info.text, tint: info.tint)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
    }
}
