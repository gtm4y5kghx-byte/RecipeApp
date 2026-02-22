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

                .accessibilityIdentifier(identifier)
        }
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel(viewModel.isPremium ? "Premium" : "Premium Features", style: .headline, color: .secondary)

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

            if !viewModel.isPremium {
                DSButton(title: "Restore Purchases", style: .tertiary, size: .small, color: Theme.Colors.textSecondary) {
                    Task { await viewModel.restorePurchases() }
                }
                .disabled(viewModel.isPurchasing)
                .accessibilityIdentifier("restore-purchases-button")
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var premiumStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("You have access to all features", style: .body, color: .secondary)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                PremiumFeatureRow.mealPlanning
                PremiumFeatureRow.suggestions
                PremiumFeatureRow.generation
            }

            if viewModel.hasActiveSubscription {
                DSButton(title: "Manage Subscription", style: .primary, size: .medium) {
                    Task { await viewModel.openSubscriptionManagement() }
                }
                .accessibilityIdentifier("manage-subscription-button")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var freeStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                PremiumFeatureRow.mealPlanning
                PremiumFeatureRow.suggestions
                PremiumFeatureRow.generation
            }

            SubscriptionCTA(
                monthlyPrice: viewModel.subscriptionPrice,
                isPurchasing: viewModel.isPurchasing
            ) {
                Task { await viewModel.purchaseSubscription() }
            }
            .accessibilityIdentifier("subscribe-button")
            .padding(.bottom, Theme.Spacing.xs)

            PremiumPurchaseCTA(
                price: viewModel.premiumPrice,
                isPurchasing: viewModel.isPurchasing,
                onPurchase: { Task { await viewModel.purchasePremium() } }
            )
            .accessibilityIdentifier("upgrade-premium-button")

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
