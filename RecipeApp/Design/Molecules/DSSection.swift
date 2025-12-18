import SwiftUI

struct DSSection<Content: View>: View {
    let title: String?
    let spacing: CGFloat
    let content: Content
    
    init(
        _ title: String? = nil,
        spacing: CGFloat = Theme.Spacing.sm,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            if let title {
                DSLabel(title, style: .title3)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
    }
}
