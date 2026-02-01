import SwiftUI

/// Design System Page Indicator Component
/// Horizontal dots showing current position in a carousel or paged view
struct DSPageIndicator: View {

    // MARK: - Configuration

    let pageCount: Int
    let currentPage: Int
    let activeColor: Color
    let inactiveColor: Color

    // MARK: - Constants

    private let dotSize: CGFloat = 8
    private let spacing: CGFloat = Theme.Spacing.sm

    // MARK: - Initializer

    init(
        pageCount: Int,
        currentPage: Int,
        activeColor: Color = Theme.Colors.primary,
        inactiveColor: Color = Theme.Colors.border
    ) {
        self.pageCount = pageCount
        self.currentPage = currentPage
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(width: dotSize, height: dotSize)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

// MARK: - Previews

#Preview("Page Indicator - Various Pages") {
    VStack(spacing: Theme.Spacing.xl) {
        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Page 1 of 4", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 4, currentPage: 0)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Page 2 of 4", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 4, currentPage: 1)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Page 3 of 4", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 4, currentPage: 2)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Page 4 of 4", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 4, currentPage: 3)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Page Indicator - Custom Colors") {
    VStack(spacing: Theme.Spacing.xl) {
        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Default (Primary)", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 5, currentPage: 2)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Accent Color", style: .caption1, color: .secondary)
            DSPageIndicator(
                pageCount: 5,
                currentPage: 2,
                activeColor: Theme.Colors.accent
            )
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("Success Color", style: .caption1, color: .secondary)
            DSPageIndicator(
                pageCount: 5,
                currentPage: 2,
                activeColor: Theme.Colors.success
            )
        }

        HStack {
            Spacer()
            VStack(spacing: Theme.Spacing.sm) {
                DSLabel("White on Dark", style: .caption1, color: .white)
                DSPageIndicator(
                    pageCount: 5,
                    currentPage: 2,
                    activeColor: .white,
                    inactiveColor: .white.opacity(0.3)
                )
            }
            Spacer()
        }
        .padding()
        .background(Theme.Colors.primary)
        .cornerRadius(Theme.CornerRadius.md)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Page Indicator - Different Counts") {
    VStack(spacing: Theme.Spacing.xl) {
        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("2 pages", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 2, currentPage: 0)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("3 pages", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 3, currentPage: 1)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("5 pages", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 5, currentPage: 2)
        }

        VStack(spacing: Theme.Spacing.sm) {
            DSLabel("7 pages", style: .caption1, color: .secondary)
            DSPageIndicator(pageCount: 7, currentPage: 3)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark: Page Indicator") {
    VStack(spacing: Theme.Spacing.xl) {
        DSPageIndicator(pageCount: 4, currentPage: 0)
        DSPageIndicator(pageCount: 4, currentPage: 1)
        DSPageIndicator(pageCount: 4, currentPage: 2)
        DSPageIndicator(pageCount: 4, currentPage: 3)
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
