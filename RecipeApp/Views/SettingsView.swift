import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel?

    init(previewViewModel: SettingsViewModel? = nil) {
        _viewModel = State(initialValue: previewViewModel)
    }

    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                SettingsContent(viewModel: viewModel)
            } else {
                DSLoadingSpinner(message: "Loading settings...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(
                    subscriptionService: UserSubscriptionService()
                )
            }
        }
    }
}

struct SettingsContent: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                displaySettingsSection
                subscriptionSection
                aboutSection
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .accessibilityIdentifier("settings-close-button")
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
    
    private var displaySettingsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Disable Auto-Lock", style: .headline, color: .secondary)

            VStack(spacing: Theme.Spacing.xs) {
                settingRow(
                    title: "Cooking Mode",
                    toggle: $viewModel.keepScreenOnInCookingMode,
                    identifier: "cooking-mode-toggle"
                )

                DSDivider(thickness: .thin, color: .prominent, spacing: .compact)

                settingRow(
                    title: "Viewing Recipes",
                    toggle: $viewModel.keepScreenOnWhileViewingRecipes,
                    identifier: "viewing-recipes-toggle"
                )
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    private func settingRow(title: String, toggle: Binding<Bool>, identifier: String) -> some View {
        HStack {
            DSLabel(title, style: .body, color: .primary)
            Spacer()
            Toggle("", isOn: toggle)
                .labelsHidden()
                .tint(colorScheme == .dark ? Theme.Colors.accent : Theme.Colors.primary)
                .scaleEffect(0.8)
                .accessibilityIdentifier(identifier)
        }
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Subscription", style: .headline, color: .secondary)

            Group {
                if viewModel.isPremium {
                    premiumStatus
                } else {
                    freeStatus
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }
    
    private var premiumStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            if viewModel.hasActiveSubscription {
                DSLabel("You have access to all features including meal planning", style: .body, color: .secondary)
                    .padding(.bottom, Theme.Spacing.sm)

                DSButton(title: "Manage Subscription", style: .primary, size: .medium) {
                    Task { await viewModel.openSubscriptionManagement() }
                }
                .accessibilityIdentifier("manage-subscription-button")
            } else {
                DSLabel("You have access to suggestions and recipe generation", style: .body, color: .secondary)

                if let price = viewModel.subscriptionPrice {
                    DSButton(
                        title: "Add Meal Planning - \(price)/month",
                        style: .primary,
                        size: .medium
                    ) {
                        Task { await viewModel.purchaseSubscription() }
                    }
                    .disabled(viewModel.isPurchasing)
                    .accessibilityIdentifier("add-subscription-button")
                }
            }
        }
    }

    private var freeStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Free Plan", style: .headline, color: .primary)

            // Subscription option (recommended)
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                DSLabel("Get everything:", style: .body, color: .secondary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    featureRow(icon: "sparkles", title: PremiumFeatureCopy.Suggestions.title)
                    featureRow(icon: "wand.and.stars", title: PremiumFeatureCopy.Generation.title)
                    featureRow(icon: "calendar", title: PremiumFeatureCopy.MealPlanning.title)
                }

                if let introPrice = viewModel.subscriptionIntroPrice,
                   let monthlyPrice = viewModel.subscriptionPrice {
                    DSButton(
                        title: "Subscribe - \(introPrice) first month",
                        style: .primary,
                        size: .medium,
                        icon: "star.fill"
                    ) {
                        Task { await viewModel.purchaseSubscription() }
                    }
                    .disabled(viewModel.isPurchasing)
                    .accessibilityIdentifier("subscribe-button")

                    DSLabel("Includes lifetime Premium access", style: .caption1, color: .secondary)
                    DSLabel("Then \(monthlyPrice)/month for Meal Planning", style: .caption1, color: .secondary)
                }
            }

            DSDivider()

            // Premium-only option
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                DSLabel("Or, just the essentials:", style: .body, color: .secondary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    featureRow(icon: "sparkles", title: PremiumFeatureCopy.Suggestions.title)
                    featureRow(icon: "wand.and.stars", title: PremiumFeatureCopy.Generation.title)
                }

                if let price = viewModel.premiumPrice {
                    DSButton(
                        title: "Buy Premium - \(price)",
                        style: .secondary,
                        size: .medium
                    ) {
                        Task { await viewModel.purchasePremium() }
                    }
                    .disabled(viewModel.isPurchasing)
                    .accessibilityIdentifier("upgrade-premium-button")

                    DSLabel("One-time purchase. No meal planning.", style: .caption1, color: .secondary)
                }
            }

            DSButton(title: "Restore Purchases", style: .tertiary, size: .small) {
                Task { await viewModel.restorePurchases() }
            }
            .disabled(viewModel.isPurchasing)
            .accessibilityIdentifier("restore-purchases-button")

            if let error = viewModel.purchaseError {
                DSLabel(error.localizedDescription, style: .caption1, color: .error)
            }
        }
    }

    private func featureRow(icon: String, title: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon(icon, size: .small, color: .adaptiveBrand)
            DSLabel(title, style: .body, color: .primary)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("About", style: .headline, color: .secondary)

            VStack(spacing: Theme.Spacing.xs) {
                aboutRow(title: "Version", value: AppConstants.appVersion)
                DSDivider(thickness: .thin, color: .prominent, spacing: .compact)
                aboutRow(title: "Privacy Policy") {
                    openURL(AppConstants.privacyPolicyURL)
                }
                DSDivider(thickness: .thin, color: .prominent, spacing: .compact)
                aboutRow(title: "Terms of Service") {
                    openURL(AppConstants.termsOfServiceURL)
                }
                DSDivider(thickness: .thin, color: .prominent, spacing: .compact)
                aboutRow(title: "Contact Support") {
                    openURL(AppConstants.supportEmailURL)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    private func aboutRow(title: String, value: String? = nil, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                DSLabel(title, style: .body, color: .primary)
                Spacer()
                if let value = value {
                    DSLabel(value, style: .body, color: .secondary)
                } else {
                    DSIcon("chevron.right", size: .small, color: .tertiary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview("Free User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: false
    )
    return SettingsView(previewViewModel: viewModel)
}

#Preview("Premium User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: true,
        hasSubscriptionOverride: false
    )
    return SettingsView(previewViewModel: viewModel)
}

#Preview("Subscriber") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: true,
        hasSubscriptionOverride: true
    )
    return SettingsView(previewViewModel: viewModel)
}

#Preview("Dark: Free User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: false
    )
    return SettingsView(previewViewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Dark: Premium User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: true,
        hasSubscriptionOverride: false
    )
    return SettingsView(previewViewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Dark: Subscriber") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: true,
        hasSubscriptionOverride: true
    )
    return SettingsView(previewViewModel: viewModel)
        .preferredColorScheme(.dark)
}
