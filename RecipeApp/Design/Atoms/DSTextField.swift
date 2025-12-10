import SwiftUI

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
        helperText: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
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

                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .foregroundColor(textColor)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .disabled(state == .disabled)
                    .focused($isFocused)
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
            icon: "text.alignleft"
        )

        DSTextField(
            placeholder: "Email address",
            text: $errorText,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            state: .error,
            helperText: "Please enter a valid email address"
        )

        DSTextField(
            placeholder: "Confirmed email",
            text: $successText,
            icon: "checkmark.circle",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            state: .success,
            helperText: "Email is valid"
        )

        DSTextField(
            placeholder: "Disabled field",
            text: .constant(""),
            state: .disabled,
            helperText: "This field is disabled"
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
            icon: "text.alignleft"
        )

        DSTextField(
            placeholder: "Source URL",
            text: $url,
            icon: "link",
            keyboardType: .URL,
            autocapitalization: .never,
            helperText: "Optional: Add the original recipe URL"
        )

        DSTextField(
            placeholder: "Number of servings",
            text: $servings,
            icon: "person.2",
            keyboardType: .numberPad
        )

        DSTextField(
            placeholder: "Add notes",
            text: $notes,
            icon: "note.text",
            helperText: "Optional cooking tips or substitutions"
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
            autocapitalization: .never
        )

        DSTextField(
            placeholder: "Phone Number",
            text: $number,
            icon: "phone",
            keyboardType: .phonePad
        )

        DSTextField(
            placeholder: "Prep Time (minutes)",
            text: $decimal,
            icon: "clock",
            keyboardType: .decimalPad
        )
    }
    .padding()
    .background(Theme.Colors.background)
}
