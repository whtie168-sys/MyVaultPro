//
//  Components.swift
//  MyVaultPro
//
//  Reusable building blocks for the premium dark UI.
//

import SwiftUI

// MARK: - Card container

struct VaultCard<Content: View>: View {
    var padding: CGFloat = Theme.Spacing.md
    var elevated: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(elevated ? Theme.cardElevated : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
    }
}

// MARK: - Background

struct VaultBackground: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            // Soft ambient glows for depth.
            Circle()
                .fill(Theme.indigo.opacity(0.16))
                .frame(width: 320, height: 320)
                .blur(radius: 120)
                .offset(x: -140, y: -260)
            Circle()
                .fill(Theme.purple.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 130)
                .offset(x: 160, y: 320)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Stat card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color
    var subtitle: String? = nil

    var body: some View {
        VaultCard(padding: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(value)
                    .font(.vaultStat)
                    .foregroundStyle(Theme.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(title)
                    .font(.vaultCaption)
                    .foregroundStyle(Theme.textSecondary)
                if let subtitle {
                    Text(subtitle)
                        .font(.vaultCaption)
                        .foregroundStyle(tint)
                }
            }
        }
    }
}

// MARK: - Icon badge

struct IconBadge: View {
    let icon: String
    let tint: Color
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(Theme.tintGradient(tint))
            Image(systemName: icon)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.vaultTitle2)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.vaultCallout)
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }
}

// MARK: - Pill / chip

struct Chip: View {
    let title: String
    var icon: String? = nil
    let tint: Color
    var selected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(title)
                .font(.vaultCaption)
        }
        .foregroundStyle(selected ? .white : tint)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(selected ? AnyShapeStyle(Theme.tintGradient(tint)) : AnyShapeStyle(tint.opacity(0.15)))
        )
    }
}

// MARK: - Primary button

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.vaultHeadline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(Theme.accentGradient)
            )
        }
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(Theme.accent)
            }
            Text(title)
                .font(.vaultTitle2)
                .foregroundStyle(Theme.textPrimary)
            Text(message)
                .font(.vaultBody)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.vaultHeadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Theme.accentGradient))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Labeled detail row

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var tint: Color = Theme.slate

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 22)
            }
            Text(label)
                .font(.vaultBody)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.vaultCallout)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tag / status badge

struct StatusBadge: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.vaultCaption)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.16)))
    }
}
