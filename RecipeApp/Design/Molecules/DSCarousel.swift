import SwiftUI

/// Design System Carousel Component
/// Swipeable horizontal pager with page indicator support
struct DSCarousel<Content: View>: View {

    // MARK: - Configuration

    let pageCount: Int
    @Binding var currentPage: Int
    let showPageIndicator: Bool
    let pageIndicatorPosition: PageIndicatorPosition
    let content: (Int) -> Content

    // MARK: - Page Indicator Position

    enum PageIndicatorPosition {
        case top
        case bottom
        case none
    }

    // MARK: - State

    @GestureState private var dragOffset: CGFloat = 0

    // MARK: - Initializer

    init(
        pageCount: Int,
        currentPage: Binding<Int>,
        showPageIndicator: Bool = true,
        pageIndicatorPosition: PageIndicatorPosition = .bottom,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.pageCount = pageCount
        self._currentPage = currentPage
        self.showPageIndicator = showPageIndicator
        self.pageIndicatorPosition = pageIndicatorPosition
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if showPageIndicator && pageIndicatorPosition == .top {
                DSPageIndicator(pageCount: pageCount, currentPage: currentPage)
                    .padding(.vertical, Theme.Spacing.md)
            }

            GeometryReader { geometry in
                pagesContainer(width: geometry.size.width)
            }

            if showPageIndicator && pageIndicatorPosition == .bottom {
                DSPageIndicator(pageCount: pageCount, currentPage: currentPage)
                    .padding(.vertical, Theme.Spacing.md)
            }
        }
    }

    // MARK: - Private Views

    private func pagesContainer(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<pageCount, id: \.self) { index in
                content(index)
                    .frame(width: width)
            }
        }
        .offset(x: -CGFloat(currentPage) * width + dragOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
        .gesture(dragGesture(pageWidth: width))
    }

    private func dragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold = pageWidth * 0.25
                let velocity = value.predictedEndTranslation.width - value.translation.width

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if value.translation.width < -threshold || velocity < -100 {
                        currentPage = min(currentPage + 1, pageCount - 1)
                    } else if value.translation.width > threshold || velocity > 100 {
                        currentPage = max(currentPage - 1, 0)
                    }
                }
            }
    }
}

// MARK: - Previews

#Preview("Carousel - Bottom Indicator") {
    @Previewable @State var page = 0

    DSCarousel(pageCount: 4, currentPage: $page) { index in
        VStack {
            Spacer()
            DSLabel("Page \(index + 1)", style: .title1, color: .primary)
            DSLabel("Swipe to navigate", style: .body, color: .secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview("Carousel - Top Indicator") {
    @Previewable @State var page = 0

    DSCarousel(
        pageCount: 3,
        currentPage: $page,
        pageIndicatorPosition: .top
    ) { index in
        VStack {
            Spacer()
            DSLabel("Page \(index + 1)", style: .title1, color: .primary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview("Carousel - No Indicator") {
    @Previewable @State var page = 0

    DSCarousel(
        pageCount: 3,
        currentPage: $page,
        showPageIndicator: false
    ) { index in
        VStack {
            Spacer()
            DSLabel("Page \(index + 1)", style: .title1, color: .primary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview("Dark: Carousel") {
    @Previewable @State var page = 0

    DSCarousel(pageCount: 4, currentPage: $page) { index in
        VStack {
            Spacer()
            DSLabel("Page \(index + 1)", style: .title1, color: .primary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.background)
    }
    .preferredColorScheme(.dark)
}
