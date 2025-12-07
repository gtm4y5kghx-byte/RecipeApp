import SwiftUI

struct ForYouSection: View {
    let isPremium: Bool
    let suggestions: [RecipeSuggestion]
    let recipes: [Recipe]
    let onRefresh: () -> Void
    let onShowPaywall: () -> Void

    var body: some View {
        if isPremium {
            if !suggestions.isEmpty {
                Section {
                    ForEach(suggestions) { suggestion in
                        if let recipe = recipes.first(where: { $0.id == suggestion.recipeID }) {
                            NavigationLink(value: recipe) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.title)
                                        .font(.headline)

                                    Text(suggestion.aiGeneratedReason)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("For You")
                        Spacer()
                        Button("Refresh") {
                            onRefresh()
                        }
                        .font(.caption)
                        .textCase(.none)
                    }
                }
            }
        } else {
            Section {
                Button(action: onShowPaywall) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.blue)
                            Text("Get Personalized Suggestions")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }

                        Text("Unlock AI-powered recipe recommendations tailored to your cooking history")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("For You")
            }
        }
    }
}
