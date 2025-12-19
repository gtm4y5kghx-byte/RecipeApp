import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    let onAISearch: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSSearchBar(
                placeholder: "Search recipes...",
                text: $text,
                onSubmit: onSubmit
            )
            
            Button(action: onAISearch) {
                DSIcon("sparkle", size: .medium, color: .primary)
                    .padding(Theme.Spacing.sm + 4)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("ai-search-button")
        }
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    
    VStack {
        Spacer()
        SearchBar(
            text: $searchText,
            onSubmit: { print("Search submitted: \(searchText)") },
            onAISearch: { print("AI search tapped") }
        )
    }
}
