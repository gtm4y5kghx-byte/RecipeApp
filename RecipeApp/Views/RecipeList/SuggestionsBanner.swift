import SwiftUI

struct SuggestionBanner: View {
    let suggestionCount: Int
    let onShowTap: () -> Void
    let onHideTap: () -> Void
    let onDismissTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("sparkles", size: .small, color: .accent)
                DSLabel("\(suggestionCount) new suggestions")
            }
            
            HStack {
                HStack(spacing: Theme.Spacing.sm) {
                    DSButton(
                        title: "Show",
                        style: .tertiary,
                        fullWidth: false,
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        action: onShowTap,
                    )
                    DSButton(
                        title: "Hide",
                        style: .tertiary,
                        fullWidth: false,
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        action: onHideTap
                    )
                }
                
                Spacer()
                
                DSButton(
                    title: "x",
                    style: .tertiary,
                    fullWidth: false,
                    horizontalPadding: 0,
                    verticalPadding: 0,
                    action: onDismissTap
                )
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }
    
}


// Add to SuggestionBanner.swift

#Preview("Suggestion Banner") {
    VStack(spacing: Theme.Spacing.md) {
        SuggestionBanner(
            suggestionCount: 3,
            onShowTap: { print("Show tapped") },
            onHideTap: { print("Hide tapped") },
            onDismissTap: { print("Dismiss tapped") }
        )
        
        SuggestionBanner(
            suggestionCount: 1,
            onShowTap: { print("Show tapped") },
            onHideTap: { print("Hide tapped") },
            onDismissTap: { print("Dismiss tapped") }
        )
        
        SuggestionBanner(
            suggestionCount: 5,
            onShowTap: { print("Show tapped") },
            onHideTap: { print("Hide tapped") },
            onDismissTap: { print("Dismiss tapped") }
        )
    }
    .padding()
    .background(Theme.Colors.background)
}
