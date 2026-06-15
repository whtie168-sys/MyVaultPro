//
//  Theme.swift
//  MyVaultPro
//
//  Central design tokens: colors, gradients, typography, spacing, radii.
//  A premium dark aesthetic inspired by Apple Wallet / Fitness / Things 3.
//

import SwiftUI

enum Theme {
    // MARK: - Core palette

    /// Near-black app background.
    static let background = Color(red: 0.043, green: 0.051, blue: 0.082)
    /// Slightly raised surface for grouped content.
    static let surface = Color(red: 0.078, green: 0.086, blue: 0.122)
    /// Card fill.
    static let card = Color(red: 0.106, green: 0.118, blue: 0.157)
    /// Elevated card (hover / hero).
    static let cardElevated = Color(red: 0.137, green: 0.149, blue: 0.196)
    /// Hairline separators / strokes.
    static let stroke = Color.white.opacity(0.08)

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.40)

    // MARK: - Accent colors

    static let indigo = Color(red: 0.42, green: 0.45, blue: 0.96)
    static let purple = Color(red: 0.65, green: 0.42, blue: 0.96)
    static let pink = Color(red: 0.96, green: 0.42, blue: 0.68)
    static let teal = Color(red: 0.27, green: 0.78, blue: 0.74)
    static let blue = Color(red: 0.30, green: 0.62, blue: 0.97)
    static let green = Color(red: 0.30, green: 0.82, blue: 0.55)
    static let amber = Color(red: 0.98, green: 0.74, blue: 0.29)
    static let orange = Color(red: 0.97, green: 0.55, blue: 0.31)
    static let slate = Color(red: 0.55, green: 0.59, blue: 0.68)

    static let accent = indigo

    // MARK: - Gradients

    static let heroGradient = LinearGradient(
        colors: [Color(red: 0.40, green: 0.36, blue: 0.92),
                 Color(red: 0.58, green: 0.36, blue: 0.92),
                 Color(red: 0.36, green: 0.52, blue: 0.95)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let accentGradient = LinearGradient(
        colors: [indigo, purple],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let splashGradient = LinearGradient(
        colors: [Color(red: 0.07, green: 0.07, blue: 0.16),
                 Color(red: 0.043, green: 0.051, blue: 0.082)],
        startPoint: .top, endPoint: .bottom)

    static func tintGradient(_ color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.55)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Metrics

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 26
        static let pill: CGFloat = 100
    }

    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 32
    }
}

// MARK: - Typography

extension Font {
    static let vaultLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let vaultTitle = Font.system(size: 26, weight: .bold, design: .rounded)
    static let vaultTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let vaultHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let vaultBody = Font.system(size: 15, weight: .regular, design: .rounded)
    static let vaultCallout = Font.system(size: 14, weight: .medium, design: .rounded)
    static let vaultCaption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let vaultStat = Font.system(size: 30, weight: .bold, design: .rounded)
    static let vaultStatLarge = Font.system(size: 40, weight: .bold, design: .rounded)
}
