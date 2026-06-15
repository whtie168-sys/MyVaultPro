//
//  DocumentEditView.swift
//  MyVaultPro
//

import SwiftUI
import CoreData

struct DocumentEditView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    let document: DocumentRecord?

    @State private var title = ""
    @State private var category: DocumentCategory = .insurance
    @State private var notes = ""
    @State private var attachmentReference = ""
    @State private var issueDate = Date()
    @State private var hasIssueDate = false
    @State private var expirationDate = Date()
    @State private var hasExpiration = false

    private var isEditing: Bool { document != nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        FormSection(title: "Document") {
                            VaultTextField(title: "Title", text: $title, placeholder: "e.g. US Passport")
                            CategoryChipPicker(title: "Category", options: DocumentCategory.allCases,
                                               selection: $category, label: { $0.rawValue },
                                               icon: { $0.icon }, tint: { $0.tint })
                        }
                        FormSection(title: "Dates") {
                            VaultDateField(title: "Issue Date", date: $issueDate, isEnabled: $hasIssueDate)
                            VaultDateField(title: "Expiration Date", date: $expirationDate, isEnabled: $hasExpiration)
                        }
                        FormSection(title: "Reference") {
                            VaultTextField(title: "Attachment Reference", text: $attachmentReference,
                                           placeholder: "e.g. file location, drawer #3")
                        }
                        FormSection(title: "Notes") {
                            VaultNotesField(title: "Notes", text: $notes)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle(isEditing ? "Edit Document" : "New Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.fontWeight(.semibold).disabled(!canSave)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let document else { return }
        title = document.title
        category = document.categoryEnum
        notes = document.notes ?? ""
        attachmentReference = document.attachmentReference ?? ""
        if let d = document.issueDate { issueDate = d; hasIssueDate = true }
        if let e = document.expirationDate { expirationDate = e; hasExpiration = true }
    }

    private func save() {
        let target = document ?? DocumentRecord(context: store.context)
        if document == nil {
            target.id = UUID()
            target.createdAt = Date()
        }
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.category = category.rawValue
        target.notes = notes.isEmpty ? nil : notes
        target.attachmentReference = attachmentReference.isEmpty ? nil : attachmentReference
        target.issueDate = hasIssueDate ? issueDate : nil
        target.expirationDate = hasExpiration ? expirationDate : nil
        target.updatedAt = Date()
        store.saveAndRefresh()
        dismiss()
    }
}
