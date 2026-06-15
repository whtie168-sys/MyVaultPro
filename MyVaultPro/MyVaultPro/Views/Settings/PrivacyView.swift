//
//  PrivacyView.swift
//  MyVaultPro
//

import SwiftUI

struct PrivacyView: View {
    private let points: [(String, String, Color, String)] = [
        ("wifi.slash", "Fully Offline", Theme.green, "All your data is stored locally on this device. Nothing is ever uploaded."),
        ("person.crop.circle.badge.xmark", "No Account", Theme.blue, "There's no sign-up, no login, and no personal information collected."),
        ("eye.slash.fill", "No Tracking", Theme.purple, "MyVault Pro contains no analytics, no ads, and no third-party trackers."),
        ("square.and.arrow.up", "You're in Control", Theme.teal, "Export your data anytime as a JSON backup, and import it back whenever you like.")
    ]

    var body: some View {
        ZStack {
            VaultBackground()
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    header
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        VaultCard {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(point.2.opacity(0.18)).frame(width: 46, height: 46)
                                    Image(systemName: point.0).font(.system(size: 20, weight: .semibold)).foregroundStyle(point.2)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(point.1).font(.vaultHeadline).foregroundStyle(Theme.textPrimary)
                                    Text(point.3).font(.vaultCaption).foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.green.opacity(0.16)).frame(width: 90, height: 90)
                Image(systemName: "lock.shield.fill").font(.system(size: 40, weight: .medium)).foregroundStyle(Theme.green)
            }
            Text("Your Privacy Comes First")
                .font(.vaultTitle2).foregroundStyle(Theme.textPrimary)
            Text("MyVault Pro is designed to keep your records completely private.")
                .font(.vaultBody).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
        .padding(.vertical, Theme.Spacing.sm)
    }
}
