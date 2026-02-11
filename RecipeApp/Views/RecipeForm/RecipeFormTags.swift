import SwiftUI

struct RecipeFormTags: View {
    @Binding var tagInput: String
    let suggestions: [(String, Int)]
    let onSelectSuggestion: (String) -> Void

    var body: some View {
        DSSection("Tags", titleColor: .accent, spacing: Theme.Spacing.md) {
            DSFormField(
                label: "Tags (comma separated)",
                placeholder: "Enter tags here",
                text: $tagInput,
                accessibilityID: "recipe-form-tags-field"
            )

            if !suggestions.isEmpty {
                ForEach(suggestions, id: \.0) { tag, count in
                    DSButton(
                        title: "\(tag) (\(count))",
                        style: .tertiary,
                        fullWidth: false
                    ) {
                        onSelectSuggestion(tag)
                    }
                }
            }
        }
    }
}
