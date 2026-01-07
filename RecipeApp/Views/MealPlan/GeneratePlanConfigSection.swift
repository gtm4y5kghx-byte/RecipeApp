import SwiftUI

struct GeneratePlanConfigSection: View {
    @Bindable var viewModel: GeneratePlanViewModel

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
                }
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        DSButton(
            title: viewModel.hasResults ? "Regenerate" : "Generate Plan",
            style: .primary,
            icon: "sparkles",
            fullWidth: true
        ) {
            Task { await viewModel.generatePlan() }
        }
        .disabled(!viewModel.canGenerate)
    }
}
