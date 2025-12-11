import SwiftUI

struct MenuButton: View {
    let action: () -> Void
    
    var body: some View {
        DSIcon("line.3.horizontal", size: .medium, color: .white)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .clipShape(Circle())
            .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
