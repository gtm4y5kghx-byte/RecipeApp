import SwiftUI

struct GeneratePlanConfigSection: View {
    @Bindable var viewModel: GeneratePlanViewModel
    let onShowPaywall: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            mealTypePicker
            dayCountPicker
            generateButton
        }
        .padding()
    }

    // MARK: - Meal Type Picker

    private var mealTypePicker: some View {
        HStack {
            DSLabel("Meal", style: .headline)
            Spacer()
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(MealType.allCases, id: \.self) { type in
                    Button {
                        viewModel.selectedMealType = type
                    } label: {
                        DSTag(
                            type.rawValue.capitalized,
                            style: viewModel.selectedMealType == type ? .primary : .outline
                        )
                    }
                    .accessibilityIdentifier("generate-plan-meal-\(type.rawValue)-button")
                }
            }
        }
    }

    // MARK: - Day Count Picker

    private var dayCountPicker: some View {
        HStack {
            DSLabel("Days", style: .headline)
            Spacer()
            HStack(spacing: Theme.Spacing.sm) {
                ForEach([3, 5, 7], id: \.self) { count in
                    Button {
                        viewModel.selectedDayCount = count
                    } label: {
                        DSTag(
                            "\(count)",
                            style: viewModel.selectedDayCount == count ? .primary : .outline
                        )
                    }
                    .accessibilityIdentifier("generate-plan-days-\(count)-button")
                }
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        VStack(spacing: Theme.Spacing.xs) {
            if viewModel.canAccessGeneration {
                DSButton(
                    title: viewModel.hasResults ? "Regenerate" : "Generate Plan",
                    style: .primary,
                    icon: "sparkles",
                    fullWidth: true
                ) {
                    Task { await viewModel.generatePlan() }
                }
                .disabled(!viewModel.canGenerate || viewModel.hasReachedWeeklyLimit)
                .accessibilityIdentifier("generate-plan-generate-button")

                DSLabel(
                    "\(viewModel.remainingGenerations) generation\(viewModel.remainingGenerations == 1 ? "" : "s") left this week",
                    style: .caption1,
                    color: viewModel.hasReachedWeeklyLimit ? .warning : .secondary,
                    alignment: .center
                )
                .padding(.top, Theme.Spacing.xs)
            } else {
                DSButton(
                    title: "Generate Plan",
                    style: .primary,
                    icon: "lock.fill",
                    fullWidth: true,
                    action: onShowPaywall
                )
                .accessibilityIdentifier("generate-plan-subscribe-button")

                DSLabel(
                    "Subscription required for AI meal planning",
                    style: .caption1,
                    color: .secondary,
                    alignment: .center
                )
                .padding(.top, Theme.Spacing.xs)
            }
        }
    }
}
