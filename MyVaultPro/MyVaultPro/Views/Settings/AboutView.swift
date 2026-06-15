//
//  AboutView.swift
//  MyVaultPro
//

import SwiftUI

struct AboutView: View {
    private let features: [(String, String, Color)] = [
        ("shippingbox.fill", "Asset Tracking", Theme.indigo),
        ("square.stack.3d.up.fill", "Collections", Theme.teal),
        ("doc.text.fill", "Documents", Theme.blue),
        ("arrow.triangle.2.circlepath", "Subscriptions", Theme.pink),
        ("wrench.and.screwdriver.fill", "Maintenance", Theme.orange),
        ("chart.bar.xaxis", "Statistics", Theme.green)
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    header
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        SectionHeader(title: "What's Inside")
                        LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                            ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                                VaultCard {
                                    HStack(spacing: 10) {
                                        IconBadge(icon: feature.0, tint: feature.2, size: 36)
                                        Text(feature.1).font(.vaultCallout).foregroundStyle(Theme.textPrimary).lineLimit(1)
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                        }
                    }
                    VaultCard {
                        Text("MyVault Pro helps you organize and protect everything you own — assets, collections, documents, subscriptions, and maintenance — in one beautiful, private place.")
                            .font(.vaultBody).foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("Made with care · 100% offline")
                        .font(.vaultCaption).foregroundStyle(Theme.textTertiary)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image("icon11")
                .resizable().aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Theme.indigo.opacity(0.4), radius: 20, y: 10)
            Text("MyVault Pro").font(.vaultTitle).foregroundStyle(Theme.textPrimary)
            Text("Assets · Records · Collections")
                .font(.vaultCallout).foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, Theme.Spacing.sm)
    }
}
