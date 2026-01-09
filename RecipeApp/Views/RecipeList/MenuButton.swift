import SwiftUI

struct MenuButton: View {
    let action: () -> Void

    var body: some View {
        DSIconButton(
            "line.3.horizontal",
            size: .medium,
            style: .filledPrimary,
            accessibilityID: "recipes-menu-button",
            action: action
        )
    }
}
