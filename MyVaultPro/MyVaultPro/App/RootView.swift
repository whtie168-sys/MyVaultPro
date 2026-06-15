//
//  RootView.swift
//  MyVaultPro
//
//  Drives the top-level flow: animated splash, onboarding, then the
//  main tab interface.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !settings.hasCompletedOnboarding {
                OnboardingFlow()
                    .transition(.opacity)
            } else {
                OnboardingFlow()
                    .transition(.opacity)

            }
            
            MainTabView()
                .transition(.opacity)

        }
        .task {
            try? await Task.sleep(nanoseconds: 2_100_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}

// MARK: - Main tab interface

struct MainTabView: View {
    @EnvironmentObject private var store: DataStore

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }

            AssetListView()
                .tabItem { Label("Assets", systemImage: "shippingbox.fill") }

            CollectionListView()
                .tabItem { Label("Collections", systemImage: "square.stack.3d.up.fill") }

            RecordsHubView()
                .tabItem { Label("Records", systemImage: "doc.text.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accent)
    }
}
