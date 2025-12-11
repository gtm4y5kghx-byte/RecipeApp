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
        case .saveFailed: return "Save Failed"
        case .deleteFailed: return "Delete Failed"
        case .importFailed: return "Import Failed"
        case .invalidData: return "Invalid Recipe Data"
        }
    }

    var message: String {
        switch self {
        case .saveFailed:
            return "We couldn't save your recipe. Please try again."
        case .deleteFailed:
            return "We couldn't delete this recipe. Please try again."
        case .importFailed(let reason):
            return "We couldn't import this recipe. \(reason)"
        case .invalidData:
            return "The recipe data is incomplete or invalid."
        }
    }

    var suggestion: String? {
        switch self {
        case .saveFailed:
            return "Check that all required fields are filled out."
        case .deleteFailed:
            return "Make sure the recipe isn't currently being edited."
        case .importFailed:
            return "Try copying the recipe details manually or check if the URL is correct."
        case .invalidData:
            return "Ensure the recipe has a title and at least one ingredient or instruction."
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
        case .noResults: return "No Results"
        case .searchFailed: return "Search Failed"
        case .outOfScope: return "Out of Scope"
        }
    }

    var message: String {
        switch self {
        case .noResults:
            return "We couldn't find any recipes matching your search."
        case .searchFailed:
            return "Something went wrong while searching. Please try again."
        case .outOfScope(let details):
            return details
        }
    }

    var suggestion: String? {
        switch self {
        case .noResults:
            return "Try different keywords or browse all recipes."
        case .searchFailed:
            return "Check your connection and try again."
        case .outOfScope:
            return "This service only handles recipe and cooking-related questions."
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}

// MARK: - AI Errors

enum AIError: AppError {
    case suggestionsFailed
    case apiError(String)
    case networkError
    case premiumRequired

    var title: String {
        switch self {
        case .suggestionsFailed: return "Suggestions Unavailable"
        case .apiError: return "AI Error"
        case .networkError: return "Network Error"
        case .premiumRequired: return "Premium Feature"
        }
    }

    var message: String {
        switch self {
        case .suggestionsFailed:
            return "We couldn't generate recipe suggestions at this time."
        case .apiError(let details):
            return "AI service error: \(details)"
        case .networkError:
            return "Unable to connect to AI service. Check your internet connection."
        case .premiumRequired:
            return "AI-powered features require a premium subscription."
        }
    }

    var suggestion: String? {
        switch self {
        case .suggestionsFailed:
            return "Try again later or browse your recipes manually."
        case .apiError:
            return "Please try again. If the problem persists, contact support."
        case .networkError:
            return "Check your internet connection and try again."
        case .premiumRequired:
            return "Upgrade to premium to unlock AI features."
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
        case .unsupportedWebsite: return "Unsupported Website"
        case .parsingFailed: return "Import Failed"
        case .networkTimeout: return "Connection Timeout"
        case .invalidURL: return "Invalid URL"
        }
    }

    var message: String {
        switch self {
        case .unsupportedWebsite:
            return "This website is not supported for automatic recipe import."
        case .parsingFailed:
            return "We couldn't extract recipe data from this page."
        case .networkTimeout:
            return "The request took too long to complete."
        case .invalidURL:
            return "The URL you entered is not valid."
        }
    }

    var suggestion: String? {
        switch self {
        case .unsupportedWebsite:
            return "Try copying the recipe details manually."
        case .parsingFailed:
            return "The recipe format may not be compatible. Try adding it manually."
        case .networkTimeout:
            return "Check your internet connection and try again."
        case .invalidURL:
            return "Please enter a valid URL starting with http:// or https://"
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
        case .unknown: return "Something Went Wrong"
        case .custom(let title, _, _): return title
        }
    }

    var message: String {
        switch self {
        case .unknown: return "An unexpected error occurred."
        case .custom(_, let message, _): return message
        }
    }

    var suggestion: String? {
        switch self {
        case .unknown: return "Please try again."
        case .custom(_, _, let suggestion): return suggestion
        }
    }

    var errorDescription: String? { message }
    var failureReason: String? { message }
    var recoverySuggestion: String? { suggestion }
}
