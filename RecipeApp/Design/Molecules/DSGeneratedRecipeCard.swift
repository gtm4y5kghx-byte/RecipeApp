import SwiftUI

struct DSGeneratedRecipeCard: View {
    
    // MARK: - Configuration
    
    let title: String
    let description: String
    let cuisine: String?
    let totalTime: Int?
    let servings: Int?
    let tags: [String]
    let onSaveTap: () -> Void
    
    private let placeholderImage = "https://placehold.co/400x300"
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSImage(url: placeholderImage, height: 160)
                .cornerRadius(Theme.CornerRadius.md)
            
            DSLabel(title, style: .headline, color: .primary)
                .lineLimit(2)
            
            DSLabel(description, style: .caption1, color: .secondary)
                .lineLimit(2)
            
            if totalTime != nil || servings != nil || cuisine != nil {
                HStack(spacing: Theme.Spacing.md) {
                    if let time = totalTime {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("clock", size: .small, color: .secondary)
                            DSLabel("\(time) min", style: .caption1, color: .secondary)
                        }
                    }
                    
                    if let servings = servings {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("person.2", size: .small, color: .secondary)
                            DSLabel("\(servings)", style: .caption1, color: .secondary)
                        }
                    }
                    
                    if let cuisine = cuisine {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("fork.knife", size: .small, color: .secondary)
                            DSLabel(cuisine, style: .caption1, color: .secondary)
                        }
                    }
                }
            }
            
            if !tags.isEmpty {
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        DSTag(tag, style: .secondary, size: .small)
                    }
                }
            }
            
            DSButton(title: "Save to Collection", style: .primary, action: onSaveTap)
        }
        .padding(Theme.Spacing.md)
        .frame(width: 280)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }
}

#Preview("Generated Recipe Card") {
    DSGeneratedRecipeCard(
        title: "Mediterranean Chickpea Bowl",
        description: "A healthy grain bowl with roasted chickpeas, fresh vegetables, and tahini dressing.",
        cuisine: "Mediterranean",
        totalTime: 35,
        servings: 4,
        tags: ["Healthy", "Vegetarian", "Quick"],
        onSaveTap: {}
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Generated Recipe Cards - Horizontal Scroll") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: Theme.Spacing.md) {
            DSGeneratedRecipeCard(
                title: "Mediterranean Chickpea Bowl",
                description: "A healthy grain bowl with roasted chickpeas, fresh vegetables, and tahini dressing.",
                cuisine: "Mediterranean",
                totalTime: 35,
                servings: 4,
                tags: ["Healthy", "Vegetarian"],
                onSaveTap: {}
            )
            
            DSGeneratedRecipeCard(
                title: "Spicy Korean Beef Tacos",
                description: "Fusion tacos with gochujang-marinated beef, pickled vegetables, and sriracha mayo.",
                cuisine: "Korean-Mexican",
                totalTime: 45,
                servings: 6,
                tags: ["Spicy", "Fusion"],
                onSaveTap: {}
            )
            
            DSGeneratedRecipeCard(
                title: "Lemon Herb Roasted Chicken",
                description: "Classic roasted chicken with garlic, rosemary, and a bright lemon finish.",
                cuisine: "American",
                totalTime: 75,
                servings: 4,
                tags: ["Classic", "Sunday Dinner"],
                onSaveTap: {}
            )
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    .background(Theme.Colors.background)
}
