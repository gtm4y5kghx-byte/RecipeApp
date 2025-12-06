import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingTransformSheet = false
    @State private var transformationPrompt = ""
    @State private var showDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var error: Error?
    @Query private var allRecipes: [Recipe]
    
    private var recipeVariations: [Recipe] {
        allRecipes.filter { $0.parentRecipeID == recipe.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                titleSection
                sourceSection
                metadataSection
                cookingHistorySection
                ingredientsSection
                instructionsSection
                notesSection
                variationsSection
                favoriteSection
                actionButtonSection
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: cookedThisRecipe) {
                    Label("I Cooked This", systemImage: "checkmark.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeFormView(recipe: recipe)
        }
        .sheet(isPresented: $showingTransformSheet) {
            RecipeTransformationView(recipe: recipe)
        }
        .errorAlert($error)
    }
    
    private var titleSection: some View {
        Text(recipe.title).font(.largeTitle)
    }
    
    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(recipe.sourceType.displayName, systemImage: recipe.sourceType.icon)
            
            if let sourceURL = recipe.sourceURL,
               !sourceURL.isEmpty,
               let url = URL(string: sourceURL),
               let host = url.host {
                let displayHost = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
                Link(destination: url) {
                    Text(displayHost)
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
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
    
    private var cookingHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cooking History")
                .font(.headline)
            
            if recipe.timesCooked == 0 {
                Text("Never cooked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    Text("Cooked \(recipe.timesCooked) \(recipe.timesCooked == 1 ? "time" : "times")")
                    
                    if let lastMade = recipe.lastMade {
                        Text("·")
                        Text("Last made \(formatRelativeDate(lastMade))")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
        }
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
    
    private var variationsSection: some View {
        Group {
            if !recipeVariations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Variations")
                        .font(.headline)
                    
                    ForEach(recipeVariations) { variation in
                        NavigationLink(value: variation) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(variation.title)
                                        .font(.subheadline)
                                    
                                    if let note = variation.variationNote {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
    
    private var favoriteSection: some View {
        Button(action: {
            recipe.isFavorite.toggle()
            HapticFeedback.light.trigger()
            do {
                try modelContext.save()
            } catch let saveError {
                recipe.isFavorite.toggle()
                error = saveError
            }
        }) {
            Label(
                recipe.isFavorite ? "Favorited" : "Favorite",
                systemImage: recipe.isFavorite ? "heart.fill" : "heart"
            )
            .foregroundStyle(recipe.isFavorite ? .red : .gray)
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
            
            Button(action: {
                showingTransformSheet = true
            }){
                Label("Transform", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: {
                markAsCooked()
            }){
                Label("I made this", systemImage: "checkmark.circle")
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
                do {
                    try modelContext.save()
                    HapticFeedback.warning.trigger()
                    dismiss()
                } catch let saveError {
                    error = saveError
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
        }
    }
    
    private func cookedThisRecipe() {
        recipe.timesCooked += 1
        recipe.lastMade = Date()
        
        do {
            try modelContext.save()
            HapticFeedback.success.trigger()
        } catch let saveError {
            recipe.timesCooked -= 1
            recipe.lastMade = nil
            error = saveError
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
    
    private func markAsCooked() {
        recipe.lastMade = Date()
        recipe.timesCooked += 1
        
        do {
            try modelContext.save()
            HapticFeedback.success.trigger()
        } catch let saveError {
            error = saveError
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        guard let days = components.day else {
            return "recently"
        }
        
        if days == 0 {
            return "today"
        } else if days == 1 {
            return "yesterday"
        } else if days < 7 {
            return "\(days) days ago"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
        } else if days < 365 {
            let months = days / 30
            return "\(months) \(months == 1 ? "month" : "months") ago"
        } else {
            let years = days / 365
            return "\(years) \(years == 1 ? "year" : "years") ago"
        }
    }
}
