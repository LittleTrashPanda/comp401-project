import SwiftUI

/// A pill-shaped tag in selectable, static or removable form.
struct ChipView: View {
    enum Kind {
        case selectable(isSelected: Bool, action: () -> Void)
        case display
        case removable(onRemove: () -> Void)
    }

    let title: String
    let kind: Kind

    init(_ title: String, kind: Kind = .display) {
        self.title = title
        self.kind = kind
    }

    var body: some View {
        switch kind {
        case .display:
            label(isSelected: false)
        case let .selectable(isSelected, action):
            Button(action: action) {
                label(isSelected: isSelected)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        case let .removable(onRemove):
            Button(action: onRemove) {
                HStack(spacing: Spacing.xxs) {
                    Text(title)
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .accessibilityHidden(true)
                }
                .chipBackground(isSelected: true)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Remove filter \(title)"))
        }
    }

    private func label(isSelected: Bool) -> some View {
        Text(title)
            .chipBackground(isSelected: isSelected)
    }
}

private extension View {
    func chipBackground(isSelected: Bool) -> some View {
        self
            .font(.footnote.weight(.medium))
            .foregroundStyle(isSelected ? .journalCobalt : .journalInk)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs)
            .frame(minHeight: Sizing.minimumTapTarget)
            .background(isSelected ? .journalCobaltSoft : .journalSurface, in: .capsule)
            .overlay(Capsule().strokeBorder(isSelected ? .journalCobalt : .journalRule, lineWidth: Sizing.hairline))
            .contentShape(.capsule)
    }
}

#Preview("Variants") {
    VStack(alignment: .leading, spacing: Spacing.s) {
        HStack {
            ChipView("All dishes", kind: .selectable(isSelected: true, action: {}))
            ChipView("Eliza", kind: .selectable(isSelected: false, action: {}))
        }
        ChipView("Contains gluten")
        ChipView("8+ average", kind: .removable(onRemove: {}))
    }
    .padding()
}

#Preview("Accessibility size") {
    VStack(alignment: .leading) {
        ChipView("Contains shellfish", kind: .selectable(isSelected: true, action: {}))
        ChipView("Last visited 3+ weeks ago", kind: .removable(onRemove: {}))
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
