import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class RecipeListViewModel {
    var filteredResults: [Recipe] = []
    var isSearching: Bool = false
    var searchTask: Task<Void, Never>?
    var suggestions: [UnifiedSuggestion] = []
    var suggestionError: AIError?
    var selectedSection: MenuSection = .all
    private var recipes: [Recipe]
    private let modelContext: ModelContext
    private let suggestionService: UnifiedSuggestionProviding

    /// Debounce delay for search. Set to `.zero` in tests for immediate execution.
    var searchDebounceDelay: Duration = .milliseconds(300)

    var error: Error?

    private var menuState: AppMenuState?

    init(
        recipes: [Recipe],
        modelContext: ModelContext,
        menuState: AppMenuState? = nil,
        suggestionService: UnifiedSuggestionProviding? = nil
    ) {
        self.recipes = recipes
        self.modelContext = modelContext
        self.menuState = menuState
        self.suggestionService = suggestionService ?? UnifiedSuggestionService()
        updateMenuState()
    }

    func updateMenuState() {
        menuState?.filterOptions = filterMenuOptions
        menuState?.tagOptions = tagMenuOptions
        menuState?.onSelectOption = { [weak self] optionId in
            self?.selectMenuOption(optionId)
        }
    }
    
    static let filterSections: [MenuSection] = [
        .all,
        .recentlyAdded,
        .recentlyCooked,
        .favorites,
        .uncategorized
    ]
    
    func updateRecipes(_ recipes: [Recipe]) {
        self.recipes = recipes
        updateMenuState()
    }

    // MARK: - Computed Properties

    var hasRecipes: Bool {
        !recipes.isEmpty
    }

    var displayedRecipes: [Recipe] {
        let filtered = isSearching ? filteredResults : recipes
        
        let sectionFiltered: [Recipe]
        switch selectedSection {
        case .all:
            sectionFiltered = filtered
        case .recentlyAdded:
            sectionFiltered = filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .recentlyCooked:
            sectionFiltered = filtered
                .filter { recipe in
                    guard let lastMade = recipe.lastMade else { return false }
                    return lastMade.isWithinDays(TimeConstants.recentlyCookedThreshold)
                }
                .sorted { ($0.lastMade ?? .distantPast) > ($1.lastMade ?? .distantPast) }
        case .favorites:
            sectionFiltered = filtered.filter { $0.isFavorite }
        case .uncategorized:
            sectionFiltered = filtered.filter { $0.userTags.isEmpty }
        case .tag(let tagName):
            sectionFiltered = filtered.filter { $0.userTags.contains(tagName) }
        }
        
        // Always prioritize suggested recipes at top when available
        let suggested = sectionFiltered.filter { suggestedRecipeIDs.contains($0.id) }
        let regular = sectionFiltered.filter { !suggestedRecipeIDs.contains($0.id) }
        
        return suggested + regular
    }
    
    var sortedTags: [(String, Int)] {
        let allTags = recipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return tagCounts
    }
    
    var hasActiveFilter: Bool {
        selectedSection != .all
    }
    
    var filterTitle: String? {
        hasActiveFilter ? selectedSection.title : nil
    }
    
    var filterIcon: String? {
        hasActiveFilter ? selectedSection.icon : nil
    }
    
    var filterMenuOptions: [MenuOption] {
        Self.filterSections.map { section in
            MenuOption(
                id: section.id,
                title: section.title,
                icon: section.icon,
                count: recipeCount(for: section)
            )
        }
    }
    
    var tagMenuOptions: [MenuOption] {
        sortedTags.map { tag, count in
            let section = MenuSection.tag(tag)
            return MenuOption(
                id: section.id,
                title: section.title,
                icon: section.icon,
                count: count
            )
        }
    }
    


    var suggestedRecipeIDs: Set<UUID> {
        Set(suggestions.compactMap { $0.recipeID })
    }

    var suggestionReasons: [UUID: String] {
        Dictionary(uniqueKeysWithValues: suggestions.compactMap { suggestion -> (UUID, String)? in
            guard let recipeID = suggestion.recipeID else { return nil }
            return (recipeID, suggestion.reason)
        })
    }

    var aiGeneratedSuggestions: [UnifiedSuggestion] {
        suggestions.filter { $0.isAIGenerated }
    }

    var displayedItems: [RecipeListItem] {
        let isFilteringOrSearching = isSearching || selectedSection != .all

        if isFilteringOrSearching {
            return buildFilteredItems()
        } else {
            return buildAllItems()
        }
    }

    // MARK: - Methods
    
    func toggleFavorite(_ recipe: Recipe) {
        recipe.isFavorite.toggle()
        do {
            try modelContext.save()
        } catch {
            self.error = error
        }
    }
    
    func recipeCount(for section: MenuSection) -> Int {
        switch section {
        case .all:
            return recipes.count
        case .recentlyAdded:
            return recipes.count
        case .recentlyCooked:
            return recipes.filter { recipe in
                guard let lastMade = recipe.lastMade else { return false }
                return lastMade.isWithinDays(TimeConstants.recentlyCookedThreshold)
            }.count
        case .favorites:
            return recipes.filter { $0.isFavorite }.count
        case .uncategorized:
            return recipes.filter { $0.userTags.isEmpty }.count
        case .tag(let tagName):
            return recipes.filter { $0.userTags.contains(tagName) }.count
        }
    }
    
    func performSearch(query: String, scope: SearchScope) {
        searchTask?.cancel()

        // Clear search immediately without debounce
        guard !query.isEmpty else {
            filteredResults = []
            isSearching = false
            return
        }

        searchTask = Task {
            if searchDebounceDelay > .zero {
                try? await Task.sleep(for: searchDebounceDelay)
            }
            guard !Task.isCancelled else { return }

            isSearching = true
            
            let results = recipes.filter { recipe in
                switch scope {
                case .all:
                    return matchesAnyField(recipe: recipe, query: query)
                case .title:
                    return substringMatch(query: query, in: recipe.title)
                case .cuisine:
                    return matchesCuisine(recipe: recipe, query: query)
                case .ingredients:
                    return matchesIngredients(recipe: recipe, query: query)
                case .instructions:
                    return matchesInstructions(recipe: recipe, query: query)
                case .notes:
                    return matchesNotes(recipe: recipe, query: query)
                }
            }
            
            filteredResults = results
        }
    }
    
    func loadSuggestionsIfEligible() async {
        guard recipes.count >= 10 else { return }
        await loadSuggestions()
    }
    
    // MARK: - Private Helpers
    
    private func matchesAnyField(recipe: Recipe, query: String) -> Bool {
        if substringMatch(query: query, in: recipe.title) {
            return true
        }
        
        if matchesCuisine(recipe: recipe, query: query) {
            return true
        }
        
        if matchesIngredients(recipe: recipe, query: query) {
            return true
        }
        
        if matchesInstructions(recipe: recipe, query: query) {
            return true
        }
        
        if matchesNotes(recipe: recipe, query: query) {
            return true
        }
        
        return false
    }
    
    private func matchesIngredients(recipe: Recipe, query: String) -> Bool {
        for ingredient in recipe.ingredients {
            if substringMatch(query: query, in: ingredient.item) {
                return true
            }
        }
        return false
    }
    
    private func matchesInstructions(recipe: Recipe, query: String) -> Bool {
        for step in recipe.instructions {
            if substringMatch(query: query, in: step.instruction) {
                return true
            }
        }
        return false
    }
    
    private func matchesCuisine(recipe: Recipe, query: String) -> Bool {
        if let cuisine = recipe.cuisine {
            return substringMatch(query: query, in: cuisine)
        }
        return false
    }
    
    private func matchesNotes(recipe: Recipe, query: String) -> Bool {
        if let notes = recipe.notes {
            return substringMatch(query: query, in: notes)
        }
        return false
    }
    
    private func substringMatch(query: String, in text: String) -> Bool {
        let query = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let text = text.lowercased()

        guard !query.isEmpty else { return false }

        return text.contains(query)
    }

    private func buildFilteredItems() -> [RecipeListItem] {
        let recipes = displayedRecipes

        // Suggested recipes at top with reasons, regular recipes below
        // No AI-generated when filtering/searching
        return recipes.map { recipe in
            let reason = suggestionReasons[recipe.id]
            return .recipe(recipe, suggestionReason: reason)
        }
    }

    private func buildAllItems() -> [RecipeListItem] {
        let recipes = displayedRecipes
        let aiGenerated = aiGeneratedSuggestions

        // Separate suggested and regular recipes
        let suggestedRecipes = recipes.filter { suggestedRecipeIDs.contains($0.id) }
        let regularRecipes = recipes.filter { !suggestedRecipeIDs.contains($0.id) }

        var items: [RecipeListItem] = []

        // 1. Collection suggestions at top with reasons
        for recipe in suggestedRecipes {
            let reason = suggestionReasons[recipe.id]
            items.append(.recipe(recipe, suggestionReason: reason))
        }

        // 2. Intersperse AI-generated among regular recipes
        items.append(contentsOf: interleaveItems(regularRecipes: regularRecipes, aiGenerated: aiGenerated))

        return items
    }

    private func interleaveItems(regularRecipes: [Recipe], aiGenerated: [UnifiedSuggestion]) -> [RecipeListItem] {
        let interval = 5 // Insert 1 AI-generated every 5 regular recipes
        var items: [RecipeListItem] = []
        var aiIndex = 0

        for (index, recipe) in regularRecipes.enumerated() {
            items.append(.recipe(recipe, suggestionReason: nil))

            // After every `interval` recipes, insert an AI-generated if available
            if (index + 1) % interval == 0 && aiIndex < aiGenerated.count {
                if let generated = aiGenerated[aiIndex].generatedRecipe {
                    items.append(.generatedRecipe(generated, reason: aiGenerated[aiIndex].reason))
                    aiIndex += 1
                }
            }
        }

        // Append any remaining AI-generated at the end
        while aiIndex < aiGenerated.count {
            if let generated = aiGenerated[aiIndex].generatedRecipe {
                items.append(.generatedRecipe(generated, reason: aiGenerated[aiIndex].reason))
            }
            aiIndex += 1
        }

        return items
    }

    func handlePendingImport() {
        do {
            if let importData = try checkForPendingImport() {
                try createRecipeFromImport(importData)
            }
        } catch {
            self.error = error
        }
    }
    
    func loadSuggestionsDev() async {
        suggestionError = nil
        do {
            suggestions = try await suggestionService.getUnifiedSuggestions(recipes: recipes, forceRefresh: true)
        } catch {
            suggestionError = .suggestionsFailed
            suggestions = []
        }
    }

    func loadSuggestions() async {
        suggestionError = nil
        do {
            suggestions = try await suggestionService.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)
        } catch {
            suggestionError = .suggestionsFailed
            suggestions = []
        }
    }

    @discardableResult
    func saveGeneratedRecipe(_ generatedRecipe: GeneratedRecipe) -> Recipe? {
        let recipe = generatedRecipe.toRecipe()

        // Add "AI Generated" tag if not already present
        if !recipe.userTags.contains("AI Generated") {
            recipe.userTags.append("AI Generated")
        }

        modelContext.insert(recipe)
        do {
            try modelContext.save()
        } catch {
            self.error = error
            return nil
        }

        // Remove from suggestions list
        suggestions.removeAll { $0.generatedRecipe?.id == generatedRecipe.id }

        return recipe
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        do {
            try modelContext.save()
        } catch {
            self.error = error
        }
    }
    
    func selectMenuOption(_ optionId: String) {
        if let section = menuSectionFromId(optionId) {
            selectedSection = section
        }
    }
    
    private func menuSectionFromId(_ id: String) -> MenuSection? {
        switch id {
        case "all": return .all
        case "recently-added": return .recentlyAdded
        case "recently-cooked": return .recentlyCooked
        case "favorites": return .favorites
        case "uncategorized": return .uncategorized
        default:
            if id.hasPrefix("tag-") {
                let tagName = String(id.dropFirst(4))
                return .tag(tagName)
            }
            return nil
        }
    }
    
    private func checkForPendingImport() throws -> RecipeImportData? {
        guard SharedDataManager.shared.hasPendingImport() else {
            return nil
        }
        
        if let importData = try SharedDataManager.shared.loadPendingImport() {
            try SharedDataManager.shared.deletePendingImport()
            return importData
        }
        
        return nil
    }
    
    private func createRecipeFromImport(_ importData: RecipeImportData) throws {
        let recipe = Recipe(title: importData.title, sourceType: .web_imported)
        recipe.sourceURL = importData.sourceURL
        recipe.imageURL = importData.imageURL
        recipe.servings = importData.servings
        recipe.prepTime = importData.prepTime
        recipe.cookTime = importData.cookTime
        recipe.cuisine = importData.cuisine
        recipe.notes = importData.description
        
        for (index, ingredientText) in importData.ingredients.enumerated() {
            let ingredient = Ingredient(quantity: "", unit: nil, item: ingredientText, preparation: nil, section: nil)
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }
        
        for (index, instructionText) in importData.instructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipe.instructions.append(step)
        }
        
        if let nutritionData = importData.nutrition {
            let nutritionInfo = NutritionInfo(
                calories: nutritionData.calories,
                carbohydrates: nutritionData.carbohydrates,
                protein: nutritionData.protein,
                fat: nutritionData.fat,
                fiber: nutritionData.fiber,
                sodium: nutritionData.sodium,
                sugar: nutritionData.sugar
            )
            recipe.nutrition = nutritionInfo
        }
        
        modelContext.insert(recipe)
        try modelContext.save()
    }
}

enum MenuSection: Hashable, Identifiable {
    case all
    case recentlyAdded
    case recentlyCooked
    case favorites
    case uncategorized
    case tag(String)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .recentlyAdded: return "recently-added"
        case .recentlyCooked: return "recently-cooked"
        case .favorites: return "favorites"
        case .uncategorized: return "uncategorized"
        case .tag(let name): return "tag-\(name)"
        }
    }
    
    var title: String {
        switch self {
        case .all: return String(localized: "All")
        case .recentlyAdded: return String(localized: "Recently Added")
        case .recentlyCooked: return String(localized: "Recently Cooked")
        case .favorites: return String(localized: "Favorites")
        case .uncategorized: return String(localized: "Uncategorized")
        case .tag(let name): return name  // User-provided, not localized
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "book"
        case .recentlyAdded: return "clock.arrow.circlepath"
        case .recentlyCooked: return "clock"
        case .favorites: return "heart.fill"
        case .uncategorized: return "tray"
        case .tag: return "tag"
        }
    }
}
