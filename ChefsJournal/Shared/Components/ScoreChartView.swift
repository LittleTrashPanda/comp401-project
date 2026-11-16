import Charts
import SwiftUI

/// A line of actual scores (no smoothing), each point labelled, on a fixed 0–10 axis.
struct ScoreChartView: View {
    struct Point: Identifiable, Hashable {
        let id = UUID()
        let date: Date
        let score: Int
    }

    struct Series: Identifiable {
        let name: LocalizedStringResource
        let points: [Point]
        let color: Color
        var isDashed = false

        var id: String { String(localized: name) }
    }

    let series: [Series]
    private static let gridValues = [0, 5, 10]
    private static let dash: [CGFloat] = [4, 3]

    var body: some View {
        Chart {
            ForEach(series) { line in
                ForEach(line.points) { point in
                    LineMark(x: .value("Date", point.date), y: .value("Score", point.score),
                             series: .value("Series", String(localized: line.name)))
                        .foregroundStyle(line.color)
                        .lineStyle(StrokeStyle(lineWidth: Sizing.stampStroke, dash: line.isDashed ? Self.dash : []))
                    PointMark(x: .value("Date", point.date), y: .value("Score", point.score))
                        .foregroundStyle(line.color)
                        .annotation(position: .top) {
                            Text(point.score, format: .number)
                                .font(.caption2)
                                .foregroundStyle(line.color)
                        }
                }
            }
        }
        .chartYScale(domain: 0...ScoreRange.maximum)
        .chartYAxis {
            AxisMarks(values: Self.gridValues) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartLegend(series.count > 1 ? .visible : .hidden)
        .frame(height: Sizing.chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilitySummary))
    }

    private var accessibilitySummary: String {
        series.map { line in
            let scores = line.points.map { String($0.score) }.joined(separator: ", ")
            return String(localized: "\(String(localized: line.name)) scores, oldest first: \(scores)")
        }
        .joined(separator: ". ")
    }
}

private enum ChartPreviewData {
    static func points(_ scores: [Int]) -> [ScoreChartView.Point] {
        scores.enumerated().map { index, score in
            .init(date: Date.now.addingTimeInterval(Double(index - scores.count) * 86_400 * 14), score: score)
        }
    }
}

#Preview("Two points") {
    ScoreChartView(series: [.init(name: "Experience", points: ChartPreviewData.points([8, 9]), color: .journalTomato)])
        .padding()
}

#Preview("Six points") {
    ScoreChartView(series: [.init(name: "Experience", points: ChartPreviewData.points([8, 9, 7, 8, 7, 8]), color: .journalTomato)])
        .padding()
}

#Preview("Twenty points, taste and value, dark") {
    let taste = (0..<20).map { 5 + $0 % 5 }
    let value = (0..<20).map { 9 - $0 % 4 }
    ScoreChartView(series: [
        .init(name: "Taste", points: ChartPreviewData.points(taste), color: .journalCobalt),
        .init(name: "Value", points: ChartPreviewData.points(value), color: .journalCobalt, isDashed: true),
    ])
    .padding()
    .preferredColorScheme(.dark)
}
