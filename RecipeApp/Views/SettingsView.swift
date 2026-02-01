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
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
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
                    DSIcon("xmark", size: .medium, color: .accent)
                }
                .accessibilityIdentifier("settings-close-button")
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
    
    private var displaySettingsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("Display", style: .title3, color: .primary)
            
            settingRow(
                icon: "moon.fill",
                title: "Keep Screen On in Cooking Mode",
                toggle: $viewModel.keepScreenOnInCookingMode,
                identifier: "cooking-mode-toggle"
            )

            DSDivider()

            settingRow(
                icon: "eye.fill",
                title: "Keep Screen On While Viewing Recipes",
                toggle: $viewModel.keepScreenOnWhileViewingRecipes,
                identifier: "viewing-recipes-toggle"
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }
    
    private func settingRow(icon: String, title: String, toggle: Binding<Bool>, identifier: String) -> some View {
        HStack {
            DSIcon(icon, size: .medium, color: .primary)
            DSLabel(title, style: .body, color: .primary)
            Spacer()
            Toggle("", isOn: toggle)
                .labelsHidden()
                .accessibilityIdentifier(identifier)
        }
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("Subscription", style: .title3, color: .primary)
            
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
    
    private var premiumStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                DSIcon("star.fill", size: .medium, color: .accent)
                DSLabel(viewModel.hasActiveSubscription ? "Subscriber" : "Premium", style: .headline, color: .primary)
            }

            if viewModel.hasActiveSubscription {
                DSLabel("You have access to all features including meal planning", style: .body, color: .secondary)

                DSButton(title: "Manage Subscription", style: .secondary, size: .medium) {
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

            DSButton(title: "Restore Purchases", style: .tertiary, size: .small) {
                Task { await viewModel.restorePurchases() }
            }
            .disabled(viewModel.isPurchasing)
            .accessibilityIdentifier("restore-purchases-button")
        }
    }

    private var freeStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Free Plan", style: .headline, color: .primary)

            DSLabel("Upgrade to unlock:", style: .body, color: .secondary)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                featureBullet("AI Suggestions")
                featureBullet("AI Recipe Generation")
                featureBullet("AI Meal Planning")
            }
            .padding(.leading, Theme.Spacing.md)

            if let price = viewModel.premiumPrice {
                DSButton(
                    title: "Upgrade to Premium - \(price)",
                    style: .primary,
                    size: .medium,
                    icon: "star.fill"
                ) {
                    Task { await viewModel.purchasePremium() }
                }
                .disabled(viewModel.isPurchasing)
                .accessibilityIdentifier("upgrade-premium-button")
            }

            if let subPrice = viewModel.subscriptionPrice {
                DSButton(
                    title: "Subscribe - \(subPrice)/month",
                    style: .secondary,
                    size: .medium
                ) {
                    Task { await viewModel.purchaseSubscription() }
                }
                .disabled(viewModel.isPurchasing)
                .accessibilityIdentifier("subscribe-button")

                DSLabel("Includes Premium forever, even if you cancel", style: .caption1, color: .tertiary)
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
    
    private func featureBullet(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            DSIcon("checkmark.circle.fill", size: .small, color: .success)
            DSLabel(text, style: .body, color: .primary)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("About", style: .title3, color: .primary)

            aboutRow(icon: "info.circle", title: "Version", value: AppConstants.appVersion)
            DSDivider()
            aboutRow(icon: "doc.text", title: "Privacy Policy") {
                openURL(AppConstants.privacyPolicyURL)
            }
            DSDivider()
            aboutRow(icon: "doc.text", title: "Terms of Service") {
                openURL(AppConstants.termsOfServiceURL)
            }
            DSDivider()
            aboutRow(icon: "envelope", title: "Contact Support") {
                openURL(AppConstants.supportEmailURL)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func aboutRow(icon: String, title: String, value: String? = nil, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                DSIcon(icon, size: .medium, color: .primary)
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

#Preview("Settings - Premium User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: true
    )
    return SettingsView(previewViewModel: viewModel)
}

#Preview("Settings - Free User") {
    let viewModel = SettingsViewModel(
        subscriptionService: UserSubscriptionService(),
        isPremiumOverride: false
    )
    return SettingsView(previewViewModel: viewModel)
}
