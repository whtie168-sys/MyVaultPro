//
//  DocumentDetailView.swift
//  MyVaultPro
//

import SwiftUI

struct DocumentDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var document: DocumentRecord

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    private var daysToExpiry: Int? {
        guard let exp = document.expirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: exp).day
    }

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    header
                    if document.expirationDate != nil { expirySection }
                    detailsSection
                    if let notes = document.notes, !notes.isEmpty {
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
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showEdit = true } } }
        .toolbarBackground(Theme.background, for: .navigationBar)
        .sheet(isPresented: $showEdit) { DocumentEditView(document: document) }
        .confirmationDialog("Delete this document?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(document); dismiss() }
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(Theme.tintGradient(document.categoryEnum.tint))
                    .frame(height: 150)
                VStack(spacing: 10) {
                    Image(systemName: document.categoryEnum.icon)
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(document.category)
                        .font(.vaultCallout)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }

    private var expirySection: some View {
        VaultCard(elevated: true) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expiration")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(Format.date(document.expirationDate))
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                if let days = daysToExpiry {
                    StatusBadge(text: days < 0 ? "Expired" : Format.relativeDays(days),
                                tint: days < 0 ? Theme.orange : (days <= 30 ? Theme.amber : Theme.green))
                }
            }
        }
    }

    private var detailsSection: some View {
        VaultCard {
            VStack(spacing: 2) {
                DetailRow(label: "Category", value: document.category, icon: document.categoryEnum.icon, tint: document.categoryEnum.tint)
                Divider().overlay(Theme.stroke)
                DetailRow(label: "Issue Date", value: Format.date(document.issueDate), icon: "calendar", tint: Theme.blue)
                if let ref = document.attachmentReference, !ref.isEmpty {
                    Divider().overlay(Theme.stroke)
                    DetailRow(label: "Reference", value: ref, icon: "paperclip", tint: Theme.slate)
                }
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            HStack { Image(systemName: "trash.fill"); Text("Delete Document") }
                .font(.vaultCallout).foregroundStyle(Theme.orange)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous).fill(Theme.orange.opacity(0.12)))
        }
        .padding(.top, Theme.Spacing.sm)
    }
}
