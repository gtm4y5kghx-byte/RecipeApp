import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel?
    
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
                DSLabel("Premium", style: .headline, color: .primary)
            }
            
            DSLabel("You have access to all premium features", style: .body, color: .secondary)
            
            DSButton(title: "Manage Subscription", style: .secondary, size: .medium) {
                // TODO: Open subscription management
            }
            .accessibilityIdentifier("manage-subscription-button")
        }
    }
    
    private var freeStatus: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Free Plan", style: .headline, color: .primary)
            
            DSLabel("Upgrade to unlock:", style: .body, color: .secondary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                featureBullet("Recipe Transformation")
                featureBullet("Unlimited Recipe Discovery")
                featureBullet("AI Meal Planning (Coming Soon)")
                featureBullet("AI Recipe Generation (Coming Soon)")
            }
            .padding(.leading, Theme.Spacing.md)
            
            DSButton(
                title: "Upgrade to Premium",
                style: .primary,
                size: .medium,
                icon: "star.fill"
            ) {
                // TODO: Open upgrade flow
            }
            .accessibilityIdentifier("upgrade-premium-button")
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
            
            aboutRow(icon: "info.circle", title: "Version", value: "1.0.0")
            DSDivider()
            aboutRow(icon: "doc.text", title: "Privacy Policy")
            DSDivider()
            aboutRow(icon: "doc.text", title: "Terms of Service")
            DSDivider()
            aboutRow(icon: "envelope", title: "Contact Support")
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }
    
    private func aboutRow(icon: String, title: String, value: String? = nil) -> some View {
        Button {
            // TODO: Handle navigation for each row
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
    }
}

#Preview("Settings View") {
    SettingsView()
}

#Preview("Settings - Premium User") {
    SettingsView()
}

#Preview("Settings - Free User") {
    SettingsView()
}
