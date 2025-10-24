import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                titleSection
                sourceSection
                metadataSection
                ingredientsSection
                instructionsSection
                notesSection
                favoriteAndRatingSection
                actionButtonSection
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .sheet(isPresented: $showingEditSheet) {
            RecipeFormView(recipe: recipe)
        }
    }
    
    private var titleSection: some View {
        Text(recipe.title).font(.largeTitle)
    }
    
    private var sourceSection: some View {
        Label(recipe.sourceType.displayName, systemImage: recipe.sourceType.icon)
    }
    
    private var metadataSection: some View {
        HStack(spacing: 16) {
            if let prepTime = recipe.prepTime {
                Label("\(prepTime) min", systemImage: "clock")
            }
            
            if let cookTime = recipe.cookTime {
                Label("\(cookTime) min", systemImage: "flame")
            }
            
            if let servings = recipe.servings {
                Label("\(servings) servings", systemImage: "fork.knife")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
            
            ForEach(recipe.ingredients.sorted(by: { $0.order < $1.order })) { ingredient in
                HStack(alignment: .top) {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                    
                    Text(ingredientText(for: ingredient))
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)
            
            ForEach(Array(recipe.instructions.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text(step.instruction)
                }
            }
        }
    }
    
    private var notesSection: some View {
        Group {
            if let notes = recipe.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var favoriteAndRatingSection: some View {
        HStack(spacing: 24) {
            Button(action: {
                recipe.isFavorite.toggle()
                try? modelContext.save()
            }) {
                Label(
                    recipe.isFavorite ? "Favorited" : "Favorite",
                    systemImage: recipe.isFavorite ? "heart.fill" : "heart"
                )
                .foregroundStyle(recipe.isFavorite ? .red : .gray)
            }
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        recipe.rating = star
                        try? modelContext.save()
                    }) {
                        Image(systemName: star <= (recipe.rating ?? 0) ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
    
    private var actionButtonSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingEditSheet = true
            }){
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }){
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: {
                // TODO: Implement share
            }){
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(recipe)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
        }
    }
    
    private func ingredientText(for ingredient: Ingredient) -> String {
        var parts: [String] = []
        
        if !ingredient.quantity.isEmpty {
            parts.append(ingredient.quantity)
        }
        if let unit = ingredient.unit {
            parts.append(unit)
        }
        parts.append(ingredient.item)
        if let prep = ingredient.preparation {
            parts.append(prep)
        }
        
        return parts.joined(separator: " ")
    }
}

// #Preview {
//     RecipeDetailView(recipe: ...)  // Need sample data
// }


