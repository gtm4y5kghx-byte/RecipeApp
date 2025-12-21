import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSSearchBar(
                placeholder: "Search recipes...",
                text: $text,
                onSubmit: onSubmit
            )
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
        )
    }
}
