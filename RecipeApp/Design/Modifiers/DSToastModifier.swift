import SwiftUI

struct DSToastModifier<BannerContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let duration: TimeInterval
    let edge: VerticalEdge
    let banner: () -> BannerContent

    func body(content: Content) -> some View {
        content.overlay(alignment: edge == .top ? .top : .bottom) {
            if isPresented {
                banner()
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(edge == .top ? .top : .bottom, Theme.Spacing.sm)
                    .transition(.move(edge: edge == .top ? .top : .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation { isPresented = false }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

extension View {
    func toast<Content: View>(
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0,
        edge: VerticalEdge = .bottom,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(DSToastModifier(isPresented: isPresented, duration: duration, edge: edge, banner: content))
    }
}

// MARK: - Previews

#Preview("Toast - Bottom") {
    @Previewable @State var show = true

    VStack {
        Button("Show Toast") { show = true }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Colors.background)
    .toast(isPresented: $show) {
        DSBanner(message: "Added to Shopping List", icon: "checkmark.circle", style: .success)
    }
}

#Preview("Toast - Top") {
    @Previewable @State var show = true

    VStack {
        Button("Show Toast") { show = true }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Colors.background)
    .toast(isPresented: $show, edge: .top) {
        DSBanner(message: "Added to Meal Plan", icon: "checkmark.circle", style: .success)
    }
}

#Preview("Dark: Toast") {
    @Previewable @State var show = true

    VStack {
        Button("Show Toast") { show = true }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Colors.background)
    .toast(isPresented: $show) {
        DSBanner(message: "Added to Shopping List", icon: "checkmark.circle", style: .success)
    }
    .preferredColorScheme(.dark)
}
