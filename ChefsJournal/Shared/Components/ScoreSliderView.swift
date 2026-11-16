import SwiftUI

/// A 0–10 slider where 0 means "Unset" (shown as "—").
struct ScoreSliderView: View {
    let title: LocalizedStringKey
    @Binding var score: Int
    var tint: Color = .journalCobalt
    var accessibilityIdentifier = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.callout.weight(.semibold))
                Spacer()
                scoreText
                    .font(.journalScore)
                    .foregroundStyle(score == ScoreRange.unset ? .journalMuted : tint)
            }
            Slider(value: sliderValue, in: 0...Double(ScoreRange.maximum), step: 1) {
                Text(title)
            }
            .tint(tint)
            .accessibilityValue(accessibilityValue)
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }

    @ViewBuilder
    private var scoreText: some View {
        if score == ScoreRange.unset {
            Text("—")
                .accessibilityLabel(Text("Unset"))
        } else {
            Text(score, format: .number)
        }
    }

    private var accessibilityValue: Text {
        score == ScoreRange.unset ? Text("Unset") : Text("\(score) out of 10")
    }

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(score) },
            set: { score = Int($0.rounded()) }
        )
    }
}

#Preview("Unset and set") {
    @Previewable @State var unset = 0
    @Previewable @State var set = 7
    VStack(spacing: Spacing.section) {
        ScoreSliderView(title: "Restaurant experience", score: $unset, tint: .journalTomato)
        ScoreSliderView(title: "Taste", score: $set)
    }
    .padding()
}

#Preview("Accessibility size") {
    @Previewable @State var score = 4
    ScoreSliderView(title: "Value", score: $score)
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
