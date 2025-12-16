import SwiftUI

struct FilterRow: View {

    let title: String
    let icon: String
    let count: Int?
    let accessibilityId: String?
    let onTap: () -> Void

    init(
        title: String,
        icon: String,
        count: Int? = nil,
        accessibilityId: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.count = count
        self.accessibilityId = accessibilityId
        self.onTap = onTap
    }

    var body: some View {
        let button = Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                DSIcon(icon, size: .medium, color: .primary)

                DSLabel(title, style: .body, color: .primary)

                if let count = count {
                    DSLabel("(\(count))", style: .body, color: .secondary)
                }

                Spacer()

                DSIcon("chevron.right", size: .small, color: .tertiary)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())

        if let accessibilityId = accessibilityId {
            button.accessibilityIdentifier(accessibilityId)
        } else {
            button
        }
    }
}
