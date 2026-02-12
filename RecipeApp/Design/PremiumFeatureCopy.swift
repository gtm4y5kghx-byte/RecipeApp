import Foundation

enum PremiumFeatureCopy {

    enum MealPlanning {
        static let title = String(localized: "AI Meal Planning")
        static let description = String(localized: "Generate weekly plans from your recipes")
    }

    enum Suggestions {
        static let title = String(localized: "Recipe Suggestions")
        static let description = String(localized: "Get personalized recommendations")
    }

    enum Generation {
        static let title = String(localized: "Recipe Generation")
        static let description = String(localized: "Create new recipes with AI")
    }
}
