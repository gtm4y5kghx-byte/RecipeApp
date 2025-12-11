import SwiftUI

/// Design System Form Field
/// Combines label, text field, and helper/error text into a single component
struct DSFormField: View {

    // MARK: - Configuration

    let label: String
    let placeholder: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    let isRequired: Bool
    let helperText: String?
    let errorText: String?

    @Binding var text: String

    // MARK: - Computed State

    private var fieldState: DSTextField.FieldState {
        if let errorText = errorText, !errorText.isEmpty {
            return .error
        }
        return .normal
    }

    private var displayHelperText: String? {
        errorText ?? helperText
    }

    // MARK: - Initializer

    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        isRequired: Bool = false,
        helperText: String? = nil,
        errorText: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.isRequired = isRequired
        self.helperText = helperText
        self.errorText = errorText
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            // Label with optional required indicator
            HStack(spacing: Theme.Spacing.xs) {
                DSLabel(label, style: .subheadline, color: .primary)

                if isRequired {
                    DSLabel("*", style: .subheadline, color: .error)
                }
            }

            // Text field
            DSTextField(
                placeholder: placeholder,
                text: $text,
                icon: icon,
                keyboardType: keyboardType,
                autocapitalization: autocapitalization,
                state: fieldState,
                helperText: displayHelperText
            )
        }
    }
}

// MARK: - Secure Variant

/// Form field for passwords
struct DSSecureFormField: View {

    let label: String
    let placeholder: String
    let icon: String?
    let isRequired: Bool
    let helperText: String?
    let errorText: String?

    @Binding var text: String

    private var fieldState: DSTextField.FieldState {
        if let errorText = errorText, !errorText.isEmpty {
            return .error
        }
        return .normal
    }

    private var displayHelperText: String? {
        errorText ?? helperText
    }

    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = "lock",
        isRequired: Bool = false,
        helperText: String? = nil,
        errorText: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isRequired = isRequired
        self.helperText = helperText
        self.errorText = errorText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.xs) {
                DSLabel(label, style: .subheadline, color: .primary)

                if isRequired {
                    DSLabel("*", style: .subheadline, color: .error)
                }
            }

            DSSecureField(
                placeholder: placeholder,
                text: $text,
                icon: icon,
                state: fieldState,
                helperText: displayHelperText
            )
        }
    }
}

// MARK: - Previews

#Preview("Form Field States") {
    @Previewable @State var title = ""
    @Previewable @State var email = "user@example.com"
    @Previewable @State var invalidEmail = "not-an-email"
    @Previewable @State var url = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSFormField(
            label: "Recipe Title",
            placeholder: "Enter recipe name",
            text: $title,
            icon: "text.alignleft",
            isRequired: true,
            helperText: "Give your recipe a descriptive name"
        )

        DSFormField(
            label: "Email Address",
            placeholder: "you@example.com",
            text: $email,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            helperText: "We'll never share your email"
        )

        DSFormField(
            label: "Email Address",
            placeholder: "you@example.com",
            text: $invalidEmail,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            errorText: "Please enter a valid email address"
        )

        DSFormField(
            label: "Source URL",
            placeholder: "https://...",
            text: $url,
            icon: "link",
            keyboardType: .URL,
            autocapitalization: .never,
            helperText: "Optional: Link to original recipe"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Form Example") {
    @Previewable @State var title = ""
    @Previewable @State var cuisine = ""
    @Previewable @State var servings = ""
    @Previewable @State var prepTime = ""
    @Previewable @State var cookTime = ""

    ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
            DSLabel("New Recipe", style: .largeTitle)

            DSDivider(spacing: .standard)

            DSFormField(
                label: "Recipe Title",
                placeholder: "Spaghetti Carbonara",
                text: $title,
                icon: "text.alignleft",
                isRequired: true,
                helperText: "Give your recipe a memorable name"
            )

            DSFormField(
                label: "Cuisine Type",
                placeholder: "Italian",
                text: $cuisine,
                icon: "fork.knife",
                helperText: "e.g., Italian, Mexican, Thai"
            )

            HStack(spacing: Theme.Spacing.md) {
                DSFormField(
                    label: "Servings",
                    placeholder: "4",
                    text: $servings,
                    icon: "person.2",
                    keyboardType: .numberPad
                )

                DSFormField(
                    label: "Prep Time",
                    placeholder: "15",
                    text: $prepTime,
                    icon: "clock",
                    keyboardType: .numberPad,
                )
            }

            DSFormField(
                label: "Cook Time",
                placeholder: "30",
                text: $cookTime,
                icon: "timer",
                keyboardType: .numberPad,
                helperText: "minutes"
            )

            DSDivider(spacing: .standard)

            DSButton(title: "Save Recipe", style: .primary, icon: "checkmark") {}
                .disabled(title.isEmpty)
        }
        .padding()
    }
    .background(Theme.Colors.background)
}

#Preview("Required Fields") {
    @Previewable @State var username = ""
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    @Previewable @State var confirmPassword = "different"

    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Create Account", style: .largeTitle)
        DSLabel("Fields marked with * are required", style: .caption1, color: .secondary)

        DSDivider(spacing: .standard)

        DSFormField(
            label: "Username",
            placeholder: "johndoe",
            text: $username,
            icon: "person",
            autocapitalization: .never,
            isRequired: true
        )

        DSFormField(
            label: "Email",
            placeholder: "you@example.com",
            text: $email,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            isRequired: true
        )

        DSSecureFormField(
            label: "Password",
            placeholder: "Enter password",
            text: $password,
            isRequired: true,
            helperText: "Must be at least 8 characters"
        )

        DSSecureFormField(
            label: "Confirm Password",
            placeholder: "Re-enter password",
            text: $confirmPassword,
            isRequired: true,
            errorText: "Passwords do not match"
        )

        DSButton(title: "Create Account", style: .primary) {}
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Validation States") {
    @Previewable @State var validField = "valid@email.com"
    @Previewable @State var invalidField = "invalid"
    @Previewable @State var emptyRequired = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Form Validation", style: .headline)

        DSFormField(
            label: "Valid Email",
            placeholder: "you@example.com",
            text: $validField,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            helperText: "Email is valid ✓"
        )

        DSFormField(
            label: "Invalid Email",
            placeholder: "you@example.com",
            text: $invalidField,
            icon: "envelope",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            errorText: "Please enter a valid email address"
        )

        DSFormField(
            label: "Required Field",
            placeholder: "Cannot be empty",
            text: $emptyRequired,
            isRequired: true,
            errorText: emptyRequired.isEmpty ? "This field is required" : nil
        )
    }
    .padding()
    .background(Theme.Colors.background)
}
