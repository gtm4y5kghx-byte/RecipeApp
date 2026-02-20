import SwiftUI

/// Design System Loading Spinner
/// Displays a loading indicator with optional message
struct DSLoadingSpinner: View {

    // MARK: - Configuration

    let message: String?
    let size: SpinnerSize

    @State private var isAnimating = false

    // MARK: - Spinner Size

    enum SpinnerSize {
        case small
        case medium
        case large

        var diameter: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 40
            case .large: return 60
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .small: return 2.5
            case .medium: return 3.5
            case .large: return 5
            }
        }
    }

    // MARK: - Initializer

    init(
        message: String? = nil,
        size: SpinnerSize = .medium
    ) {
        self.message = message
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Theme.Colors.primary,
                            Theme.Colors.secondary,
                            Theme.Colors.accent,
                            Theme.Colors.primary
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size.lineWidth, lineCap: .round)
                )
                .frame(width: size.diameter, height: size.diameter)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear { isAnimating = true }

            if let message = message {
                DSLabel(message, style: .body, color: .secondary, alignment: .center)
            }
        }
    }
}

// MARK: - Full Screen Variant

/// Full screen loading overlay
struct DSLoadingOverlay: View {

    let message: String?

    @State private var isAnimating = false

    init(message: String? = "Loading...") {
        self.message = message
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                // Custom white gradient spinner for overlay
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .white,
                                .white.opacity(0.8),
                                .white.opacity(0.5),
                                .white
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear { isAnimating = true }

                if let message = message {
                    DSLabel(message, style: .headline, color: .white, alignment: .center)
                }
            }
            .padding(Theme.Spacing.xl)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Previews

#Preview("Loading Spinner Sizes") {
    VStack(spacing: Theme.Spacing.xl) {
        DSLoadingSpinner(message: "Small spinner", size: .small)
        DSLoadingSpinner(message: "Medium spinner", size: .medium)
        DSLoadingSpinner(message: "Large spinner", size: .large)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Loading Spinner - No Message") {
    VStack(spacing: Theme.Spacing.xl) {
        DSLoadingSpinner(size: .small)
        DSLoadingSpinner(size: .medium)
        DSLoadingSpinner(size: .large)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Loading Spinner Messages") {
    VStack(spacing: Theme.Spacing.xl) {
        DSLoadingSpinner(message: "Loading recipes...")
        DSLoadingSpinner(message: "Importing recipe from web...")
        DSLoadingSpinner(message: "Generating AI suggestions...")
        DSLoadingSpinner(message: "Saving changes...")
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Loading Overlay") {
    ZStack {
        // Mock content underneath
        VStack(spacing: Theme.Spacing.md) {
            DSLabel("Recipe List", style: .largeTitle)

            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.backgroundLight)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(Theme.Colors.background)

        // Loading overlay on top
        DSLoadingOverlay(message: "Loading recipes...")
    }
}

#Preview("Loading Overlay Variations") {
    TabView {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            DSLoadingOverlay(message: "Importing recipe...")
        }
        .tabItem { Label("Import", systemImage: "square.and.arrow.down") }

        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            DSLoadingOverlay(message: "Generating suggestions...")
        }
        .tabItem { Label("AI", systemImage: "sparkles") }

        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            DSLoadingOverlay(message: nil)
        }
        .tabItem { Label("Simple", systemImage: "circle") }
    }
}

#Preview("Loading in Context") {
    VStack(spacing: 0) {
        // Header
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                DSLabel("My Recipes", style: .largeTitle)
                Spacer()
            }

        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)

        // Loading state
        VStack {
            Spacer()
            DSLoadingSpinner(message: "Searching recipes...")
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview("Loading States Comparison") {
    VStack(spacing: Theme.Spacing.xxl) {
        VStack(spacing: Theme.Spacing.md) {
            DSLabel("Inline Loading", style: .headline)
            DSLoadingSpinner(message: "Loading...", size: .small)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)

        VStack(spacing: Theme.Spacing.md) {
            DSLabel("Card Loading", style: .headline)
            DSLoadingSpinner(message: "Fetching data...", size: .medium)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)

        VStack(spacing: Theme.Spacing.md) {
            DSLabel("Full Page Loading", style: .headline)
            Spacer()
            DSLoadingSpinner(message: "Loading recipes...", size: .large)
            Spacer()
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Loading with Action Button") {
    VStack(spacing: Theme.Spacing.xl) {
        Spacer()

        DSLoadingSpinner(message: "This is taking longer than usual...", size: .large)

        DSButton(title: "Cancel", style: .secondary) {}
            .padding(.horizontal, Theme.Spacing.xl)

        Spacer()
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Dark Mode Previews

#Preview("Dark: Loading Spinners") {
    VStack(spacing: Theme.Spacing.xl) {
        DSLoadingSpinner(message: "Loading recipes...", size: .small)
        DSLoadingSpinner(message: "Generating suggestions...", size: .medium)
        DSLoadingSpinner(message: "Importing recipe...", size: .large)
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("Dark: Loading Overlay") {
    ZStack {
        VStack(spacing: Theme.Spacing.md) {
            DSLabel("Recipe List", style: .largeTitle)
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.backgroundLight)
                    .frame(height: 80)
            }
        }
        .padding()
        .background(Theme.Colors.background)

        DSLoadingOverlay(message: "Loading...")
    }
    .preferredColorScheme(.dark)
}
