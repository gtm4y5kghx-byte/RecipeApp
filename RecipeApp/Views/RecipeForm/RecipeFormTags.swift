import SwiftUI

struct RecipeFormTags: View {
    @Binding var tagInput: String
    let suggestions: [(String, Int)]
    let onSelectSuggestion: (String) -> Void

    @FocusState private var isFieldFocused: Bool

    var body: some View {
        DSSection("Tags", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
            DSTextField(
                placeholder: "Enter tags (comma separated)",
                text: $tagInput,
                accessibilityID: "recipe-form-tags-field"
            )
            .focused($isFieldFocused)

            if isFieldFocused && !suggestions.isEmpty {
                FlowLayout(spacing: Theme.Spacing.xs) {
                    ForEach(suggestions, id: \.0) { tag, count in
                        Button {
                            onSelectSuggestion(tag)
                        } label: {
                            DSTag("\(tag) (\(count))", style: .secondary, size: .medium)
                        }
                        .accessibilityIdentifier("tag-suggestion-\(tag)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
