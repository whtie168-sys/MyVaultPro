//
//  FormComponents.swift
//  MyVaultPro
//
//  Shared form building blocks: styled fields, photo picker, date toggles.
//

import SwiftUI
import PhotosUI

// MARK: - Form section card

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textTertiary)
                .padding(.leading, 4)
            VaultCard {
                VStack(spacing: 14) { content }
            }
        }
    }
}

// MARK: - Text field

struct VaultTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
            TextField(placeholder, text: $text)
                .font(.vaultBody)
                .foregroundStyle(Theme.textPrimary)
                .keyboardType(keyboard)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surface))
        }
    }
}

// MARK: - Number field

struct VaultNumberField: View {
    let title: String
    @Binding var value: Double
    var prefix: String = "$"

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 4) {
                Text(prefix)
                    .font(.vaultBody)
                    .foregroundStyle(Theme.textSecondary)
                TextField("0", text: $text)
                    .font(.vaultBody)
                    .foregroundStyle(Theme.textPrimary)
                    .keyboardType(.decimalPad)
                    .onChange(of: text) { newValue in
                        value = Double(newValue.filter { "0123456789.".contains($0) }) ?? 0
                    }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surface))
        }
        .onAppear {
            if value != 0 { text = value == value.rounded() ? String(Int(value)) : String(value) }
        }
    }
}

// MARK: - Multiline notes

struct VaultNotesField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
            TextField("Add notes…", text: $text, axis: .vertical)
                .font(.vaultBody)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(3...6)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.surface))
        }
    }
}

// MARK: - Category picker (chips)

struct CategoryChipPicker<T: Hashable>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String
    let icon: (T) -> String
    let tint: (T) -> Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button { selection = option } label: {
                            Chip(title: label(option), icon: icon(option),
                                 tint: tint(option), selected: selection == option)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// MARK: - Optional date field

struct VaultDateField: View {
    let title: String
    @Binding var date: Date
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $isEnabled.animation()) {
                Text(title)
                    .font(.vaultCaption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .tint(Theme.accent)
            if isEnabled {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Photo picker

struct VaultPhotoPicker: View {
    @Binding var imageData: Data?
    @State private var selection: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo")
                .font(.vaultCaption)
                .foregroundStyle(Theme.textSecondary)
            PhotosPicker(selection: $selection, matching: .images) {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                self.imageData = nil
                                self.selection = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white, .black.opacity(0.5))
                                    .padding(8)
                            }
                        }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.accent)
                        Text("Add Photo")
                            .font(.vaultCallout)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(Theme.stroke)
                    )
                }
            }
            .onChange(of: selection) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        // Downscale to keep the store lean.
                        imageData = downscale(data)
                    }
                }
            }
        }
    }

    private func downscale(_ data: Data, maxDimension: CGFloat = 1000) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1)
        if scale >= 1 { return image.jpegData(compressionQuality: 0.8) ?? data }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.8) ?? data
    }
}

// MARK: - Photo thumbnail / placeholder for lists & detail

struct PhotoThumbnail: View {
    let data: Data?
    let fallbackIcon: String
    let tint: Color
    var size: CGFloat = 52
    var corner: CGFloat = 14

    var body: some View {
        if let data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Theme.tintGradient(tint))
                Image(systemName: fallbackIcon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
        }
    }
}
