//
//  AppSettings.swift
//  MyVaultPro
//
//  Persisted user preferences (onboarding state, theme).
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        }
    }
}

@MainActor
final class AppSettings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("appTheme") private var appThemeRaw = AppTheme.dark.rawValue

    var appTheme: AppTheme {
        get { AppTheme(rawValue: appThemeRaw) ?? .dark }
        set { appThemeRaw = newValue.rawValue; objectWillChange.send() }
    }
}
