//
//  Charts.swift
//  MyVaultPro
//
//  Lightweight custom charts built from SwiftUI shapes so the app
//  has no external dependencies and a consistent premium look.
//

import SwiftUI

struct ChartDatum: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    var tint: Color = Theme.indigo
}

// MARK: - Bar chart

struct BarChartView: View {
    let data: [ChartDatum]
    var height: CGFloat = 160
    var valueFormatter: (Double) -> String = { "\(Int($0))" }

    private var maxValue: Double { max(data.map(\.value).max() ?? 1, 1) }

    var body: some View {
        if data.isEmpty {
            placeholder
        } else {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data) { datum in
                    VStack(spacing: 8) {
                        Text(valueFormatter(datum.value))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Theme.tintGradient(datum.tint))
                            .frame(height: barHeight(for: datum.value))
                            .frame(maxWidth: .infinity)
                        Text(datum.label)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
            .frame(height: height + 30)
        }
    }

    private func barHeight(for value: Double) -> CGFloat {
        max(CGFloat(value / maxValue) * height, 4)
    }

    private var placeholder: some View {
        Text("No data yet")
            .font(.vaultBody)
            .foregroundStyle(Theme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: height)
    }
}

// MARK: - Line chart

struct LineChartView: View {
    let data: [ChartDatum]
    var tint: Color = Theme.teal
    var height: CGFloat = 160

    private var maxValue: Double { max(data.map(\.value).max() ?? 1, 1) }

    var body: some View {
        if data.count < 2 {
            Text("Not enough data yet")
                .font(.vaultBody)
                .foregroundStyle(Theme.textTertiary)
                .frame(maxWidth: .infinity, minHeight: height)
        } else {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    let points = pointPositions(in: geo.size)
                    ZStack {
                        // Area fill
                        areaPath(points: points, in: geo.size)
                            .fill(LinearGradient(colors: [tint.opacity(0.35), tint.opacity(0.02)],
                                                 startPoint: .top, endPoint: .bottom))
                        // Line
                        linePath(points: points)
                            .stroke(Theme.tintGradient(tint),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        // Dots
                        ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                            Circle()
                                .fill(tint)
                                .frame(width: 7, height: 7)
                                .position(point)
                        }
                    }
                }
                .frame(height: height)
                HStack {
                    ForEach(data) { datum in
                        Text(datum.label)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func pointPositions(in size: CGSize) -> [CGPoint] {
        guard data.count > 1 else { return [] }
        let stepX = size.width / CGFloat(data.count - 1)
        return data.enumerated().map { index, datum in
            let x = CGFloat(index) * stepX
            let y = size.height - (CGFloat(datum.value / maxValue) * (size.height - 10)) - 5
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        return path
    }

    private func areaPath(points: [CGPoint], in size: CGSize) -> Path {
        var path = linePath(points: points)
        guard let first = points.first, let last = points.last else { return path }
        path.addLine(to: CGPoint(x: last.x, y: size.height))
        path.addLine(to: CGPoint(x: first.x, y: size.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Progress card

struct ProgressCard: View {
    let title: String
    let value: String
    let progress: Double // 0...1
    let tint: Color
    var caption: String? = nil

    var body: some View {
        VaultCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.vaultCallout)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text(value)
                        .font(.vaultHeadline)
                        .foregroundStyle(Theme.textPrimary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.stroke)
                            .frame(height: 10)
                        Capsule()
                            .fill(Theme.tintGradient(tint))
                            .frame(width: max(geo.size.width * min(max(progress, 0), 1), 10), height: 10)
                    }
                }
                .frame(height: 10)
                if let caption {
                    Text(caption)
                        .font(.vaultCaption)
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
    }
}

// MARK: - Donut / ring distribution

struct DonutSegment: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let tint: Color
}

struct DonutChartView: View {
    let segments: [DonutSegment]
    var lineWidth: CGFloat = 22
    var size: CGFloat = 150

    private var total: Double { max(segments.reduce(0) { $0 + $1.value }, 0.0001) }

    var body: some View {
        ZStack {
            ForEach(Array(segmentRanges().enumerated()), id: \.offset) { _, item in
                Circle()
                    .trim(from: item.start, to: item.end)
                    .stroke(item.segment.tint,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
            VStack(spacing: 2) {
                Text("\(segments.count)")
                    .font(.vaultTitle)
                    .foregroundStyle(Theme.textPrimary)
                Text("types")
                    .font(.vaultCaption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }

    private func segmentRanges() -> [(segment: DonutSegment, start: CGFloat, end: CGFloat)] {
        var running: Double = 0
        return segments.map { segment in
            let start = running / total
            running += segment.value
            let end = running / total
            return (segment, CGFloat(start), CGFloat(end))
        }
    }
}
