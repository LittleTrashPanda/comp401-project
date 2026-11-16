import SwiftUI

/// Step 2: area (new restaurants only), date, visit type, experience score and note.
struct VisitDetailsStep: View {
    @ObservedObject var viewModel: NewVisitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.section) {
            Text(viewModel.draft.restaurantName)
                .font(.journalRowName)
                .foregroundStyle(.journalCobalt)
            if viewModel.isNewRestaurant {
                JournalTextField(title: "Area or address (optional)", text: $viewModel.draft.restaurantArea)
            }
            DatePicker("Date", selection: $viewModel.draft.date, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.compact)
            Picker("Visit type", selection: $viewModel.draft.visitType) {
                ForEach(VisitType.allCases, id: \.self) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(.segmented)
            ScoreSliderView(title: "Restaurant experience", score: $viewModel.draft.experienceScore,
                            tint: .journalTomato, accessibilityIdentifier: "experienceSlider")
            JournalTextField(title: "What should future you remember?", text: $viewModel.draft.note, isMultiline: true)
        }
    }
}

/// A labelled text field on the surface colour, used across the forms.
struct JournalTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var isMultiline = false
    var accessibilityIdentifier = ""

    private static let multilineRange = 3...6

    var body: some View {
        Group {
            if isMultiline {
                TextField(title, text: $text, axis: .vertical)
                    .lineLimit(Self.multilineRange)
            } else {
                TextField(title, text: $text)
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .padding(Spacing.s)
        .frame(minHeight: Sizing.minimumTapTarget)
        .background(.journalSurface, in: .rect(cornerRadius: Radius.small))
        .overlay(RoundedRectangle(cornerRadius: Radius.small).strokeBorder(.journalRule, lineWidth: Sizing.hairline))
    }
}
