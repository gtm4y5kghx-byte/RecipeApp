import UIKit

enum ScreenContext {
    case cookingMode
    case recipeDetail
}

class ScreenAwakeHelper {
    static func applySettings(for context: ScreenContext, userDefaults: UserDefaults = .standard) {
        let keepAwake = switch context {
        case .cookingMode:
            userDefaults.bool(forKey: "keepScreenOnInCookingMode")
        case .recipeDetail:
            userDefaults.bool(forKey: "keepScreenOnWhileViewingRecipes")
        }

        UIApplication.shared.isIdleTimerDisabled = keepAwake
    }

    static func reset() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
