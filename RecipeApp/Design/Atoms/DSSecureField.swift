import SwiftUI

/// Design System Secure Text Field for passwords
/// Includes show/hide password toggle button
struct DSSecureField: View {

    // MARK: - Configuration

    let placeholder: String
    let icon: String?
    let state: DSTextField.FieldState
    let helperText: String?

    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isShowingPassword = false

    // MARK: - Initializer

    init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = "lock",
        state: DSTextField.FieldState = .normal,
        helperText: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.state = state
        self.helperText = helperText
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(Theme.Typography.body)
                }

                if isShowingPassword {
                    TextField(placeholder, text: $text)
                        .font(Theme.Typography.body)
                        .foregroundColor(textColor)
                        .disabled(state == .disabled)
                        .focused($isFocused)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(Theme.Typography.body)
                        .foregroundColor(textColor)
                        .disabled(state == .disabled)
                        .focused($isFocused)
                }

                Button {
                    isShowingPassword.toggle()
                } label: {
                    Image(systemName: isShowingPassword ? "eye.slash" : "eye")
                        .foregroundColor(Theme.Colors.textSecondary)
                        .font(Theme.Typography.body)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 4)
            .background(backgroundColor)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            if let helperText = helperText {
                Text(helperText)
                    .font(Theme.Typography.caption1)
                    .foregroundColor(state.helperTextColor)
                    .padding(.leading, Theme.Spacing.xs)
            }
        }
    }

    // MARK: - Style Properties

    private var backgroundColor: Color {
        state == .disabled ? Theme.Colors.backgroundDark : Theme.Colors.backgroundLight
    }

    private var textColor: Color {
        state == .disabled ? Theme.Colors.textTertiary : Theme.Colors.textPrimary
    }

    private var iconColor: Color {
        isFocused ? state.focusedBorderColor : Theme.Colors.textSecondary
    }

    private var borderColor: Color {
        isFocused ? state.focusedBorderColor : state.borderColor
    }

    private var borderWidth: CGFloat {
        isFocused ? 2 : 1
    }
}

// MARK: - Previews

#Preview("Secure Field States") {
    @Previewable @State var password = ""
    @Previewable @State var confirmPassword = ""
    @Previewable @State var errorPassword = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSSecureField(
            placeholder: "Enter password",
            text: $password,
            helperText: "Must be at least 8 characters"
        )

        DSSecureField(
            placeholder: "Confirm password",
            text: $confirmPassword,
            state: .success,
            helperText: "Passwords match"
        )

        DSSecureField(
            placeholder: "Try again",
            text: $errorPassword,
            state: .error,
            helperText: "Passwords do not match"
        )

        DSSecureField(
            placeholder: "Disabled",
            text: .constant(""),
            state: .disabled,
            helperText: "Field is disabled"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Show/Hide Password") {
    @Previewable @State var password = "MySecretPassword123"

    VStack(spacing: Theme.Spacing.lg) {
        Text("Tap the eye icon to toggle visibility")
            .font(Theme.Typography.caption1)
            .foregroundColor(Theme.Colors.textSecondary)

        DSSecureField(
            placeholder: "Password",
            text: $password,
            helperText: "Click eye icon to show/hide"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}
