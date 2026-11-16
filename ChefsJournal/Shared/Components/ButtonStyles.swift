import SwiftUI

/// Full-width cobalt button for the main action of a screen or sheet.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: Layout.minimumTapTarget)
            .padding(.vertical, Spacing.xs)
            .background(.journalCobalt, in: .rect(cornerRadius: Radius.large))
            .opacity(isEnabled ? (configuration.isPressed ? Layout.pressedOpacity : 1) : Layout.disabledOpacity)
    }
}

/// Cobalt outline button for secondary actions such as "Add Dish".
struct OutlineButtonStyle: ButtonStyle {
    var tint: Color = .journalCobalt

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: Layout.minimumTapTarget)
            .padding(.vertical, Spacing.xs)
            .overlay(RoundedRectangle(cornerRadius: Radius.large).strokeBorder(tint, lineWidth: Layout.stampStroke))
            .contentShape(.rect(cornerRadius: Radius.large))
            .opacity(configuration.isPressed ? Layout.pressedOpacity : 1)
    }
}

/// The Journal's "New Log" button, with a solid cobalt offset shadow that collapses when pressed.
struct NewLogButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let offset = configuration.isPressed ? 0 : Layout.newLogPressedOffset
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.journalInk)
            .frame(maxWidth: .infinity, minHeight: Layout.minimumTapTarget)
            .padding(.vertical, Spacing.xs)
            .background(.journalSurface, in: .rect(cornerRadius: Radius.large))
            .overlay(RoundedRectangle(cornerRadius: Radius.large).strokeBorder(.journalInk, lineWidth: Layout.stampStroke))
            .background(
                RoundedRectangle(cornerRadius: Radius.large)
                    .fill(.journalCobalt)
                    .offset(x: offset, y: offset)
            )
            .offset(x: Layout.newLogPressedOffset - offset, y: Layout.newLogPressedOffset - offset)
            .animation(.snappy, value: configuration.isPressed)
    }
}

#Preview("Buttons") {
    VStack(spacing: Spacing.m) {
        Button("Continue") {}.buttonStyle(PrimaryButtonStyle())
        Button("Save Log") {}.buttonStyle(PrimaryButtonStyle()).disabled(true)
        Button("Add Dish", systemImage: "plus") {}.buttonStyle(OutlineButtonStyle())
        Button("New Log", systemImage: "plus") {}.buttonStyle(NewLogButtonStyle())
    }
    .padding()
    .background(.journalPaper)
}

#Preview("Accessibility size") {
    VStack(spacing: Spacing.m) {
        Button("Continue") {}.buttonStyle(PrimaryButtonStyle())
        Button("New Log", systemImage: "plus") {}.buttonStyle(NewLogButtonStyle())
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
