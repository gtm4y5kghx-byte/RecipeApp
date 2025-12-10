import SwiftUI

/// Visual catalog of the RecipeApp design system
/// Use this to preview colors, typography, spacing, and components
struct ThemePreview: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Colors") {
                    NavigationLink("Core Colors") {
                        CoreColorsPreview()
                    }
                    NavigationLink("Text Colors") {
                        TextColorsPreview()
                    }
                    NavigationLink("Semantic Colors") {
                        SemanticColorsPreview()
                    }
                }

                Section("Typography") {
                    NavigationLink("Font Scales") {
                        TypographyPreview()
                    }
                    NavigationLink("Semantic Styles") {
                        SemanticTypographyPreview()
                    }
                }

                Section("Spacing & Layout") {
                    NavigationLink("Spacing Scale") {
                        SpacingPreview()
                    }
                    NavigationLink("Corner Radius") {
                        CornerRadiusPreview()
                    }
                }
            }
            .navigationTitle("Design System")
        }
    }
}

// MARK: - Color Previews

struct CoreColorsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                colorSwatch("Primary", Theme.Colors.primary, "Main brand color for buttons and highlights")
                colorSwatch("Secondary", Theme.Colors.secondary, "Lighter burgundy for secondary actions")
                colorSwatch("Accent", Theme.Colors.accent, "Golden bronze for tags and premium features")

                Divider()

                colorSwatch("Background", Theme.Colors.background, "Main app background")
                colorSwatch("Background Light", Theme.Colors.backgroundLight, "Elevated cards and surfaces")
                colorSwatch("Background Dark", Theme.Colors.backgroundDark, "Subtle contrast areas")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Core Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    func colorSwatch(_ name: String, _ color: Color, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(color)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text(description)
                        .font(Theme.Typography.caption1)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

struct TextColorsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                textSwatch("Primary", Theme.Colors.textPrimary, "Body text, headers, navigation")
                textSwatch("Secondary", Theme.Colors.textSecondary, "Supporting text, metadata")
                textSwatch("Tertiary", Theme.Colors.textTertiary, "Placeholders, disabled states")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Text Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    func textSwatch(_ name: String, _ color: Color, _ usage: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text("The quick brown fox jumps over the lazy dog")
                .font(Theme.Typography.body)
                .foregroundColor(color)

            Text(usage)
                .font(Theme.Typography.caption1)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

struct SemanticColorsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                semanticSwatch("Success", Theme.Colors.success, "Confirmations, completed states")
                semanticSwatch("Warning", Theme.Colors.warning, "Warnings, attention needed")
                semanticSwatch("Error", Theme.Colors.error, "Errors, destructive actions")

                Divider()

                colorSwatch("Border", Theme.Colors.border, "Subtle separators, input borders")
                colorSwatch("Divider", Theme.Colors.divider, "Section dividers")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Semantic Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    func semanticSwatch(_ name: String, _ color: Color, _ usage: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                .fill(color)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(name)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)

                Text(usage)
                    .font(Theme.Typography.caption1)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()
        }
    }

    func colorSwatch(_ name: String, _ color: Color, _ usage: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Rectangle()
                .fill(color)
                .frame(height: 2)

            Text(usage)
                .font(Theme.Typography.caption1)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

// MARK: - Typography Previews

struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Display Sizes")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textSecondary)

                fontSample("Large Title", Theme.Typography.largeTitle, "34pt Bold")
                fontSample("Title 1", Theme.Typography.title1, "28pt Bold")
                fontSample("Title 2", Theme.Typography.title2, "22pt Bold")
                fontSample("Title 3", Theme.Typography.title3, "20pt Semibold")

                Divider()

                Text("Body Sizes")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textSecondary)

                fontSample("Headline", Theme.Typography.headline, "17pt Semibold")
                fontSample("Body", Theme.Typography.body, "17pt Regular")
                fontSample("Callout", Theme.Typography.callout, "16pt Regular")
                fontSample("Subheadline", Theme.Typography.subheadline, "15pt Regular")
                fontSample("Footnote", Theme.Typography.footnote, "13pt Regular")
                fontSample("Caption 1", Theme.Typography.caption1, "12pt Regular")
                fontSample("Caption 2", Theme.Typography.caption2, "11pt Regular")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Font Scales")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fontSample(_ name: String, _ font: Font, _ specs: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Text(name)
                    .font(Theme.Typography.caption1)
                    .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                Text(specs)
                    .font(Theme.Typography.caption2)
                    .foregroundColor(Theme.Colors.textTertiary)
            }

            Text("The quick brown fox")
                .font(font)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

struct SemanticTypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                semanticFontSample("Recipe Title", Theme.Typography.recipeTitle, "Main recipe heading")
                semanticFontSample("Section Header", Theme.Typography.sectionHeader, "Ingredients, Instructions headers")
                semanticFontSample("Ingredient Text", Theme.Typography.ingredientText, "Ingredient list items")
                semanticFontSample("Instruction Text", Theme.Typography.instructionText, "Step-by-step instructions")
                semanticFontSample("Metadata", Theme.Typography.metadata, "Cook time, servings, source")
                semanticFontSample("Tag", Theme.Typography.tag, "Recipe tags, categories")
                semanticFontSample("Button Label", Theme.Typography.buttonLabel, "Button text")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Semantic Styles")
        .navigationBarTitleDisplayMode(.inline)
    }

    func semanticFontSample(_ name: String, _ font: Font, _ usage: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(name)
                .font(Theme.Typography.caption1)
                .foregroundColor(Theme.Colors.textSecondary)

            Text("Sample Text")
                .font(font)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(usage)
                .font(Theme.Typography.caption2)
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Spacing Previews

struct SpacingPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Base Scale (4pt grid)")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textSecondary)

                spacingSample("XS", Theme.Spacing.xs, "4pt - Tiny gaps")
                spacingSample("SM", Theme.Spacing.sm, "8pt - Compact spacing")
                spacingSample("MD", Theme.Spacing.md, "16pt - Standard spacing")
                spacingSample("LG", Theme.Spacing.lg, "24pt - Section spacing")
                spacingSample("XL", Theme.Spacing.xl, "32pt - Large gaps")
                spacingSample("XXL", Theme.Spacing.xxl, "48pt - Extra large")

                Divider()

                Text("Semantic Spacing")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textSecondary)

                spacingSample("Card Padding", Theme.Spacing.cardPadding, "16pt")
                spacingSample("Section Gap", Theme.Spacing.sectionGap, "24pt")
                spacingSample("Item Gap", Theme.Spacing.itemGap, "8pt")
                spacingSample("Screen Edge", Theme.Spacing.screenEdge, "16pt")
                spacingSample("Button Padding", Theme.Spacing.buttonPadding, "16pt")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Spacing Scale")
        .navigationBarTitleDisplayMode(.inline)
    }

    func spacingSample(_ name: String, _ spacing: CGFloat, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Text(name)
                    .font(Theme.Typography.caption1)
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Text(description)
                    .font(Theme.Typography.caption2)
                    .foregroundColor(Theme.Colors.textTertiary)
            }

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Theme.Colors.primary)
                    .frame(width: spacing, height: 20)

                Rectangle()
                    .fill(Theme.Colors.border)
                    .frame(height: 20)
            }
        }
    }
}

struct CornerRadiusPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                radiusSample("Small", Theme.CornerRadius.sm, "8pt - Tags, small buttons")
                radiusSample("Medium", Theme.CornerRadius.md, "12pt - Cards, inputs")
                radiusSample("Large", Theme.CornerRadius.lg, "16pt - Prominent cards")
                radiusSample("Full", Theme.CornerRadius.full, "999pt - Pills, circular")
            }
            .padding()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Corner Radius")
        .navigationBarTitleDisplayMode(.inline)
    }

    func radiusSample(_ name: String, _ radius: CGFloat, _ usage: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            RoundedRectangle(cornerRadius: radius)
                .fill(Theme.Colors.primary)
                .frame(height: 60)
                .overlay(
                    Text(usage)
                        .font(Theme.Typography.caption1)
                        .foregroundColor(.white)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ThemePreview()
}
