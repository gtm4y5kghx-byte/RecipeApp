import Foundation

/// Centralized error handling for the app
/// All app errors conform to this protocol for consistent error display
protocol AppError: LocalizedError {
    var title: String { get }
    var message: String { get }
    var suggestion: String? { get }
}

// MARK: - Recipe Errors

enum RecipeError: AppError {
    case saveFailed
    case deleteFailed
    case importFailed(reason: String)
    case invalidData

    var title: String {
        switch self {
        case .saveFailed: return String(localized: "Save Failed")
        case .deleteFailed: return String(localized: "Delete Failed")
        case .importFailed: return String(localized: "Import Failed")
        case .invalidData: return String(localized: "Invalid Recipe Data")
        }
    }

    var message: String {
        switch self {
        case .saveFailed:
            return String(localized: "We couldn't save your recipe. Please try again.")
        case .deleteFailed:
            return String(localized: "We couldn't delete this recipe. Please try again.")
        case .importFailed(let reason):
            return String(localized: "We couldn't import this recipe. \(reason)")
        case .invalidData:
            return String(localized: "The recipe data is incomplete or invalid.")
        }
    }

    var suggestion: String? {
        switch self {
        case .saveFailed:
            return String(localized: "Check that all required fields are filled out.")
        case .deleteFailed:
            return String(localized: "Make sure the recipe isn't currently being edited.")
        case .importFailed:
            return String(localized: "Try copying the recipe details manually or check if the URL is correct.")
        case .invalidData:
            return String(localized: "Ensure the recipe has a title and at least one ingredient or instruction.")
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - Search Errors

enum SearchError: AppError {
    case noResults
    case searchFailed
    case outOfScope(String)

    var title: String {
        switch self {
        case .noResults: return String(localized: "No Results")
        case .searchFailed: return String(localized: "Search Failed")
        case .outOfScope: return String(localized: "Out of Scope")
        }
    }

    var message: String {
        switch self {
        case .noResults:
            return String(localized: "We couldn't find any recipes matching your search.")
        case .searchFailed:
            return String(localized: "Something went wrong while searching. Please try again.")
        case .outOfScope(let details):
            return details  // Dynamic content, not localized
        }
    }

    var suggestion: String? {
        switch self {
        case .noResults:
            return String(localized: "Try different keywords or browse all recipes.")
        case .searchFailed:
            return String(localized: "Check your connection and try again.")
        case .outOfScope:
            return String(localized: "This service only handles recipe and cooking-related questions.")
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - AI Errors

enum AIError: AppError {
    case suggestionsFailed
    case generationFailed
    case apiError(String)
    case networkError
    case premiumRequired
    case emptyCollection
    case insufficientRecipes(available: Int, required: Int)
    case parsingFailed
    case weeklyLimitReached

    var title: String {
        switch self {
        case .suggestionsFailed: return String(localized: "Suggestions Unavailable")
        case .generationFailed: return String(localized: "Generation Failed")
        case .apiError: return String(localized: "AI Error")
        case .networkError: return String(localized: "Network Error")
        case .premiumRequired: return String(localized: "Premium Feature")
        case .emptyCollection: return String(localized: "No Recipes")
        case .insufficientRecipes: return String(localized: "Not Enough Recipes")
        case .parsingFailed: return String(localized: "Processing Failed")
        case .weeklyLimitReached: return String(localized: "Weekly Limit Reached")
        }
    }

    var message: String {
        switch self {
        case .suggestionsFailed:
            return String(localized: "We couldn't generate recipe suggestions at this time.")
        case .generationFailed:
            return String(localized: "We couldn't generate new recipes at this time.")
        case .apiError(let details):
            return String(localized: "AI service error: \(details)")
        case .networkError:
            return String(localized: "Unable to connect to AI service. Check your internet connection.")
        case .premiumRequired:
            return String(localized: "AI-powered features require a premium subscription.")
        case .emptyCollection:
            return String(localized: "You don't have any recipes yet.")
        case .insufficientRecipes(let available, let required):
            return String(localized: "You have \(available) recipes, but need at least \(required) for this feature.")
        case .parsingFailed:
            return String(localized: "We couldn't process the AI response.")
        case .weeklyLimitReached:
            return String(localized: "You've used all 3 meal plan generations for this week.")
        }
    }

    var suggestion: String? {
        switch self {
        case .suggestionsFailed:
            return String(localized: "Try again later or browse your recipes manually.")
        case .generationFailed:
            return String(localized: "Try again later. Your recipe collection helps us personalize suggestions.")
        case .apiError, .parsingFailed:
            return String(localized: "Please try again. If the problem persists, contact support.")
        case .weeklyLimitReached:
            return String(localized: "Create a plan manually or wait for your limit to reset.")
        case .networkError:
            return String(localized: "Check your internet connection and try again.")
        case .premiumRequired:
            return String(localized: "Upgrade to premium to unlock AI features.")
        case .emptyCollection:
            return String(localized: "Import or create some recipes to use this feature.")
        case .insufficientRecipes:
            return String(localized: "Add more recipes to your collection for better results.")
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - Import Errors

enum ImportError: AppError {
    case unsupportedWebsite
    case parsingFailed
    case networkTimeout
    case invalidURL
    
    var title: String {
        switch self {
        case .unsupportedWebsite: return String(localized: "Unsupported Website")
        case .parsingFailed: return String(localized: "Import Failed")
        case .networkTimeout: return String(localized: "Connection Timeout")
        case .invalidURL: return String(localized: "Invalid URL")
        }
    }

    var message: String {
        switch self {
        case .unsupportedWebsite:
            return String(localized: "This website is not supported for automatic recipe import.")
        case .parsingFailed:
            return String(localized: "We couldn't extract recipe data from this page.")
        case .networkTimeout:
            return String(localized: "The request took too long to complete.")
        case .invalidURL:
            return String(localized: "The URL you entered is not valid.")
        }
    }

    var suggestion: String? {
        switch self {
        case .unsupportedWebsite:
            return String(localized: "Try copying the recipe details manually.")
        case .parsingFailed:
            return String(localized: "The recipe format may not be compatible. Try adding it manually.")
        case .networkTimeout:
            return String(localized: "Check your internet connection and try again.")
        case .invalidURL:
            return String(localized: "Please enter a valid URL starting with http:// or https://")
        }
    }
    
    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - Meal Plan Errors

enum MealPlanError: AppError {
    case saveFailed
    case deleteFailed
    case loadFailed

    var title: String {
        switch self {
        case .saveFailed: return String(localized: "Save Failed")
        case .deleteFailed: return String(localized: "Delete Failed")
        case .loadFailed: return String(localized: "Load Failed")
        }
    }

    var message: String {
        switch self {
        case .saveFailed:
            return String(localized: "We couldn't save this meal plan entry.")
        case .deleteFailed:
            return String(localized: "We couldn't remove this meal plan entry.")
        case .loadFailed:
            return String(localized: "We couldn't load your meal plan.")
        }
    }

    var suggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed, .loadFailed:
            return String(localized: "Please try again.")
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - Generic App Error

enum GenericError: AppError {
    case unknown
    case custom(title: String, message: String, suggestion: String?)
    
    var title: String {
        switch self {
        case .unknown: return String(localized: "Something Went Wrong")
        case .custom(let title, _, _): return title  // Caller responsible for localization
        }
    }

    var message: String {
        switch self {
        case .unknown: return String(localized: "An unexpected error occurred.")
        case .custom(_, let message, _): return message  // Caller responsible for localization
        }
    }

    var suggestion: String? {
        switch self {
        case .unknown: return String(localized: "Please try again.")
        case .custom(_, _, let suggestion): return suggestion  // Caller responsible for localization
        }
    }
    
    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}
