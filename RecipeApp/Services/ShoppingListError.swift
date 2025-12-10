import Foundation

enum ShoppingListError: Error, LocalizedError {
    case permissionDenied
    case listNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission to access Reminders was denied. Please enable access in Settings."
        case .listNotFound:
            return "Shopping list not found in Reminders."
        case .saveFailed:
            return "Failed to save ingredients to Reminders."
        }
    }
}
