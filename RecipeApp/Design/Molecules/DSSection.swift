import SwiftUI

struct DSSection<Content: View>: View {
    let title: String?
    let titleColor: DSLabel.LabelColor
    let spacing: CGFloat
    let titleSpacing: CGFloat
    let verticalPadding: CGFloat
    let content: Content

    init(
        _ title: String? = nil,
        titleColor: DSLabel.LabelColor = .primary,
        spacing: CGFloat = Theme.Spacing.sm,
        titleSpacing: CGFloat = Theme.Spacing.sm,
        verticalPadding: CGFloat = Theme.Spacing.sm,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleColor = titleColor
        self.spacing = spacing
        self.titleSpacing = titleSpacing
        self.verticalPadding = verticalPadding
        self.content = content()
    }

    var body: some View {
        VStack(spacing: spacing) {
            if let title {
                DSLabel(title, style: .title3, color: titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, titleSpacing)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, verticalPadding)
    }
}
