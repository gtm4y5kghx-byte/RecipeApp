import SwiftUI

struct CookingModeSteps: View {
    @Environment(\.colorScheme) private var colorScheme

    let stepItems: [CookingModeViewModel.StepItem]
    @Binding var currentIndex: Int

    private var activeDotColor: Color {
        colorScheme == .dark ? Theme.Colors.accent : Theme.Colors.primary
    }

    private var currentStepLabel: String {
        guard !stepItems.isEmpty else { return "" }
        let safeIndex = min(currentIndex, stepItems.count - 1)
        return stepItems[safeIndex].label
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()

            DSLabel(currentStepLabel, style: .metadata, color: .adaptiveBrand, alignment: .center)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: currentIndex)

            TabView(selection: $currentIndex) {
                ForEach(stepItems) { item in
                    CookingModeStepCard(item: item)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Spacer()

            // Page dots at bottom
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(0..<stepItems.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? activeDotColor : Theme.Colors.textSecondary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background)
    }
}
