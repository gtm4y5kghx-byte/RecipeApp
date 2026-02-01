import Foundation

/// Feature flags for controlling feature availability.
/// Currently returns static values - swap implementation to remote config later.
enum FeatureFlags {
    // MARK: - AI Features
    static var isAISuggestionsEnabled: Bool { true }
    static var isRecipeGenerationEnabled: Bool { true }
    static var isMealPlanAIEnabled: Bool { true }

    // MARK: - Premium Gating
    /// When false, all users get premium features (TestFlight mode)
    static var isPremiumGatingEnabled: Bool { true }
}
