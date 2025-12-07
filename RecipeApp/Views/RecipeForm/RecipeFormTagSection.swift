import SwiftUI

struct RecipeFormTagSection: View {
    @Binding var tagInput: String
    let tagSuggestions: [(String, Int)]

    var body: some View {
        Section("Tags") {
            TextField("Add tags (comma-separated)...", text: $tagInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !tagInput.isEmpty && !tagSuggestions.isEmpty {
                ForEach(tagSuggestions.prefix(5), id: \.0) { tag, count in
                    Button(action: {
                        selectTag(tag)
                    }) {
                        HStack {
                            Text(tag)
                            Spacer()
                            Text("\(count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func selectTag(_ tag: String) {
        var tags = tagInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        let existingTags = tags.dropLast()
        if existingTags.contains(tag.lowercased()) {
            tags = Array(tags.dropLast())
        } else {
            if !tags.isEmpty {
                tags[tags.count - 1] = tag.lowercased()
            } else {
                tags.append(tag.lowercased())
            }
        }

        tagInput = tags.joined(separator: ", ")
    }
}
