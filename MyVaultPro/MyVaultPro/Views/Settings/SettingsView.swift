//
//  SettingsView.swift
//  MyVaultPro
//
//  General settings hub: theme, data, privacy, about.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var store: DataStore

    @State private var showExporter = false
    @State private var showImporter = false
    @State private var exportDocument: VaultJSONDocument?
    @State private var alert: SettingsAlert?

    var body: some View {
        NavigationStack {
            ZStack {
                VaultBackground()
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        profileBanner
                        appearanceSection
                        dataSection
                        aboutSection
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Settings")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .fileExporter(isPresented: $showExporter, document: exportDocument,
                          contentType: .json, defaultFilename: "MyVaultPro-Backup") { result in
                if case .success = result { alert = .exported }
                else { alert = .error("Export failed.") }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                handleImport(result)
            }
            .alert(item: $alert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Sections

    private var profileBanner: some View {
        VaultCard(elevated: true) {
            HStack(spacing: 16) {
                Image("icon11")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text("MyVault Pro")
                        .font(.vaultTitle2)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Your private, offline vault")
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }
        }
    }

    private var appearanceSection: some View {
        SettingsGroup(title: "Appearance") {
            HStack {
                settingsLabel("Theme", "paintbrush.fill", Theme.purple)
                Spacer()
                Picker("", selection: Binding(
                    get: { settings.appTheme },
                    set: { settings.appTheme = $0 })) {
                    ForEach(AppTheme.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
        }
    }

    private var dataSection: some View {
        SettingsGroup(title: "Data") {
            Button { exportData() } label: {
                settingsRow("Export Data", "square.and.arrow.up.fill", Theme.teal, "JSON backup")
            }
            Divider().overlay(Theme.stroke)
            Button { showImporter = true } label: {
                settingsRow("Import Data", "square.and.arrow.down.fill", Theme.blue, "Merge a backup")
            }
        }
    }

    private var aboutSection: some View {
        SettingsGroup(title: "About") {
            NavigationLink { PrivacyView() } label: {
                settingsRow("Privacy", "lock.shield.fill", Theme.green, nil, chevron: true)
            }
            Divider().overlay(Theme.stroke)
            NavigationLink { AboutView() } label: {
                settingsRow("About MyVault Pro", "info.circle.fill", Theme.indigo, nil, chevron: true)
            }
            Divider().overlay(Theme.stroke)
            HStack {
                settingsLabel("Version", "number", Theme.slate)
                Spacer()
                Text(appVersion).font(.vaultCallout).foregroundStyle(Theme.textSecondary)
            }
        }
    }

    // MARK: - Row builders

    private func settingsLabel(_ title: String, _ icon: String, _ tint: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(tint.opacity(0.18)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(tint)
            }
            Text(title).font(.vaultBody).foregroundStyle(Theme.textPrimary)
        }
    }

    private func settingsRow(_ title: String, _ icon: String, _ tint: Color, _ subtitle: String?, chevron: Bool = false) -> some View {
        HStack {
            settingsLabel(title, icon, tint)
            Spacer()
            if let subtitle {
                Text(subtitle).font(.vaultCaption).foregroundStyle(Theme.textTertiary)
            }
            if chevron {
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textTertiary)
            }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    // MARK: - Actions

    private func exportData() {
        do {
            let data = try DataTransferService.export(from: store)
            exportDocument = VaultJSONDocument(data: data)
            showExporter = true
        } catch {
            alert = .error("Could not prepare export.")
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let needsAccess = url.startAccessingSecurityScopedResource()
            defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let count = try DataTransferService.import(data: data, into: store)
                alert = .imported(count)
            } catch {
                alert = .error("Could not read that file.")
            }
        case .failure:
            alert = .error("Import cancelled.")
        }
    }
}

// MARK: - Settings group card

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textTertiary)
                .padding(.leading, 4)
            VaultCard {
                VStack(spacing: 12) { content }
            }
        }
    }
}

// MARK: - Alert model

enum SettingsAlert: Identifiable {
    case exported
    case imported(Int)
    case error(String)

    var id: String {
        switch self {
        case .exported: return "exported"
        case .imported(let n): return "imported\(n)"
        case .error(let m): return "error\(m)"
        }
    }

    var title: String {
        switch self {
        case .exported: return "Export Complete"
        case .imported: return "Import Complete"
        case .error: return "Something Went Wrong"
        }
    }

    var message: String {
        switch self {
        case .exported: return "Your vault was exported successfully."
        case .imported(let n): return "Imported \(n) new record\(n == 1 ? "" : "s")."
        case .error(let m): return m
        }
    }
}

// MARK: - File document

struct VaultJSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
