import SwiftUI

/// A short confirmation that auto-dismisses after ``Timing/successToastDuration``.
struct SuccessToastView: View {
    let message: String

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "checkmark")
                .accessibilityHidden(true)
        }
        .font(.callout.weight(.semibold))
        .foregroundStyle(.journalPaper)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(.journalInk, in: .capsule)
        .accessibilityAddTraits(.isStaticText)
    }
}

private struct SuccessToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    SuccessToastView(message: message)
                        .padding(.bottom, Spacing.m)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.default, value: message)
            .task(id: message) {
                guard message != nil else { return }
                do {
                    try await Task.sleep(for: Timing.successToastDuration)
                    message = nil
                } catch {
                    // Cancelled because a newer toast replaced this one; the new task dismisses it.
                }
            }
    }
}

extension View {
    /// Shows a success toast while `message` is non-nil and clears it after 2.6 s.
    func successToast(message: Binding<String?>) -> some View {
        modifier(SuccessToastModifier(message: message))
    }
}

#Preview("Toast") {
    SuccessToastView(message: "Visit saved to your journal")
        .padding()
}

#Preview("Accessibility size") {
    SuccessToastView(message: "Visit saved to your journal")
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
