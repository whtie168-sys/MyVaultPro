//
//  SplashView.swift
//  MyVaultPro
//
//  Animated launch screen using the icon11 brand asset.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.splashGradient.ignoresSafeArea()

            // Ambient glows
            Circle().fill(Theme.indigo.opacity(0.25)).frame(width: 280, height: 280)
                .blur(radius: 110).offset(x: -120, y: -200)
            Circle().fill(Theme.purple.opacity(0.22)).frame(width: 260, height: 260)
                .blur(radius: 110).offset(x: 130, y: 240)

            VStack(spacing: 26) {
                ZStack {
                    Circle()
                        .stroke(Theme.accentGradient, lineWidth: 2)
                        .frame(width: 168, height: 168)
                        .scaleEffect(ringScale)
                        .opacity(logoOpacity * 0.6)

                    Image("icon11")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 132, height: 132)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Theme.indigo.opacity(0.5), radius: 30, y: 12)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("MyVault Pro")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Assets · Records · Collections")
                        .font(.vaultCallout)
                        .foregroundStyle(Theme.textSecondary)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
            }
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            logoScale = 1; logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 1.6)) {
            ringScale = 1.15
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
            textOffset = 0; textOpacity = 1
        }
    }
}
