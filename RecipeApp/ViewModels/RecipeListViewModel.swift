import Foundation
import SwiftUI

@MainActor
@Observable
class RecipeListViewModel {
    var filteredResults: [Recipe] = []
    var selectedSection: MenuSection = .all
    var searchTask: Task<Void, Never>?

    
    private let recipes: [Recipe]

    
    init(recipes: [Recipe]) {
        self.recipes = recipes
    }
    
    // MARK: - Computed Properties
    
    var displayedRecipes: [Recipe] {
        let filtered = filteredResults.isEmpty ? recipes : filteredResults
        
        switch selectedSection {
        case .all:
            return filtered
        case .recentlyAdded:
            return filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .recentlyCooked:
            return filtered
                .filter { recipe in
                    guard let lastMade = recipe.lastMade else { return false }
                    return lastMade.isWithinDays(TimeConstants.recentlyCookedThreshold)
                }
                .sorted { ($0.lastMade ?? .distantPast) > ($1.lastMade ?? .distantPast) }
        case .favorites:
            return filtered.filter { $0.isFavorite }
        case .uncategorized:
            return filtered.filter { $0.userTags.isEmpty }
        case .tag(let tagName):
            return filtered.filter { $0.userTags.contains(tagName) }
        }
    }
    
    var sortedTags: [(String, Int)] {
        let allTags = recipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return tagCounts
    }
    
    // MARK: - Methods
    
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
    
    func performFuzzySearch(query: String, scope: SearchScope) {
        // If query is empty, clear results
        guard !query.isEmpty else {
            filteredResults = []
            return
        }

        // Perform search based on scope
        let results = recipes.filter { recipe in
            switch scope {
            case .all:
                return matchesAnyField(recipe: recipe, query: query)
            case .title:
                return FuzzySearchService.fuzzyMatch(query: query, in: recipe.title)
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
    
    // MARK: - Private Helpers
    
    private func matchesAnyField(recipe: Recipe, query: String) -> Bool {
        if FuzzySearchService.fuzzyMatch(query: query, in: recipe.title) {
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
            if FuzzySearchService.fuzzyMatch(query: query, in: ingredient.item) {
                return true
            }
        }
        return false
    }
    
    private func matchesInstructions(recipe: Recipe, query: String) -> Bool {
        for step in recipe.instructions {
            if FuzzySearchService.fuzzyMatch(query: query, in: step.instruction) {
                return true
            }
        }
        return false
    }
    
    private func matchesNotes(recipe: Recipe, query: String) -> Bool {
        if let notes = recipe.notes {
            return FuzzySearchService.fuzzyMatch(query: query, in: notes)
        }
        return false
    }
}

enum SearchScope: String, CaseIterable {
    case all = "All"
    case title = "Title"
    case ingredients = "Ingredients"
    case instructions = "Instructions"
    case notes = "Notes"
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
        case .all: return "All"
        case .recentlyAdded: return "Recently Added"
        case .recentlyCooked: return "Recently Cooked"
        case .favorites: return "Favorites"
        case .uncategorized: return "Uncategorized"
        case .tag(let name): return name
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
