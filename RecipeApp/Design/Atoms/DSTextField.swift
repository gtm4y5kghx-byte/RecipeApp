import SwiftUI

// MARK: - Text Field

/// Design System Text Field Component
/// Consistent text input styling with optional icons and validation states
struct DSTextField: View {

    // MARK: - Configuration

    let placeholder: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    let state: FieldState
    let helperText: String?
    let accessibilityID: String

    @Binding var text: String
    @FocusState private var isFocused: Bool

    // MARK: - Field State

    enum FieldState {
        case normal
        case error
        case success
        case disabled

        var borderColor: Color {
            switch self {
            case .normal: return Theme.Colors.border
            case .error: return Theme.Colors.error
            case .success: return Theme.Colors.success
            case .disabled: return Theme.Colors.border
            }
        }

        var focusedBorderColor: Color {
            switch self {
            case .normal: return Theme.Colors.primary
            case .error: return Theme.Colors.error
            case .success: return Theme.Colors.success
            case .disabled: return Theme.Colors.border
            }
        }

        var helperTextColor: Color {
            switch self {
            case .normal: return Theme.Colors.textSecondary
            case .error: return Theme.Colors.error
            case .success: return Theme.Colors.success
            case .disabled: return Theme.Colors.textTertiary
            }
        }
    }

    // MARK: - Initializer

    init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        state: FieldState = .normal,
        helperText: String? = nil,
        accessibilityID: String
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.state = state
        self.helperText = helperText
        self.accessibilityID = accessibilityID
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

                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .foregroundColor(textColor)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .disabled(state == .disabled)
                    .focused($isFocused)
                    .accessibilityIdentifier(accessibilityID)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 4) // 12pt vertical
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
        switch state {
        case .disabled:
            return Theme.Colors.backgroundDark
        default:
            return Theme.Colors.backgroundLight
        }
    }

    private var textColor: Color {
        switch state {
        case .disabled:
            return Theme.Colors.textTertiary
        default:
            return Theme.Colors.textPrimary
        }
    }

    private var iconColor: Color {
        if isFocused {
            return state.focusedBorderColor
        } else {
            return Theme.Colors.textSecondary
        }
    }

    private var borderColor: Color {
        if isFocused {
            return state.focusedBorderColor
        } else {
            return state.borderColor
        }
    }

    private var borderWidth: CGFloat {
        isFocused ? 2 : 1
    }
}

// MARK: - Previews

#Preview("Text Field States") {
    @Previewable @State var normalText = ""
    @Previewable @State var errorText = "invalid@"
    @Previewable @State var successText = "valid@email.com"

    VStack(spacing: Theme.Spacing.lg) {
        DSTextField(
            placeholder: "Enter recipe title",
            text: $normalText,
            icon: "text.alignleft",
            accessibilityID: "preview-normal-field"
        )

        DSTextField(
            placeholder: "Email address",
            text: $errorText,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            state: .error,
            helperText: "Please enter a valid email address",
            accessibilityID: "preview-error-field"
        )

        DSTextField(
            placeholder: "Confirmed email",
            text: $successText,
            icon: "checkmark.circle",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            state: .success,
            helperText: "Email is valid",
            accessibilityID: "preview-success-field"
        )

        DSTextField(
            placeholder: "Disabled field",
            text: .constant(""),
            state: .disabled,
            helperText: "This field is disabled",
            accessibilityID: "preview-disabled-field"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Text Field Variants") {
    @Previewable @State var title = ""
    @Previewable @State var url = ""
    @Previewable @State var servings = ""
    @Previewable @State var notes = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSTextField(
            placeholder: "Recipe Title",
            text: $title,
            icon: "text.alignleft",
            accessibilityID: "preview-title"
        )

        DSTextField(
            placeholder: "Source URL",
            text: $url,
            icon: "link",
            keyboardType: .URL,
            autocapitalization: .never,
            helperText: "Optional: Add the original recipe URL",
            accessibilityID: "preview-url"
        )

        DSTextField(
            placeholder: "Number of servings",
            text: $servings,
            icon: "person.2",
            keyboardType: .numberPad,
            accessibilityID: "preview-servings"
        )

        DSTextField(
            placeholder: "Add notes",
            text: $notes,
            icon: "note.text",
            helperText: "Optional cooking tips or substitutions",
            accessibilityID: "preview-notes"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Focus States") {
    @Previewable @State var email = ""
    @Previewable @State var number = ""
    @Previewable @State var decimal = ""

    VStack(spacing: Theme.Spacing.lg) {
        Text("Tap fields to see focus state & border changes")
            .font(Theme.Typography.caption1)
            .foregroundColor(Theme.Colors.textSecondary)

        DSTextField(
            placeholder: "Email",
            text: $email,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            accessibilityID: "preview-focus-email"
        )

        DSTextField(
            placeholder: "Phone Number",
            text: $number,
            icon: "phone",
            keyboardType: .phonePad,
            accessibilityID: "preview-focus-phone"
        )

        DSTextField(
            placeholder: "Prep Time (minutes)",
            text: $decimal,
            icon: "clock",
            keyboardType: .decimalPad,
            accessibilityID: "preview-focus-prep-time"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Secure Field

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

// MARK: - Secure Field Previews

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

// MARK: - Dark Mode Previews

#Preview("Dark: Text Field States") {
    @Previewable @State var text = "Sample text"

    VStack(spacing: Theme.Spacing.lg) {
        DSTextField(
            placeholder: "Normal field",
            text: $text,
            icon: "pencil",
            accessibilityID: "sample-text-field"
        )

        DSTextField(
            placeholder: "Success state",
            text: .constant("Valid input"),
            icon: "checkmark",
            state: .success,
            helperText: "Looks good!",
            accessibilityID: "valid-text-field"
        )

        DSTextField(
            placeholder: "Error state",
            text: .constant("Invalid"),
            icon: "xmark",
            state: .error,
            helperText: "Please fix this",
            accessibilityID: "invalid-text-field"
        )

        DSTextField(
            placeholder: "Disabled",
            text: .constant(""),
            state: .disabled,
            accessibilityID: "disabled-text-field"
        )
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
