import SwiftUI

struct LayoutPrototypesView: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // SIDEBAR
            List {
                Text("Filter 1")
                Text("Filter 2")
                Text("Filter 3")
            }
            .navigationTitle("Filters")
        } detail: {
            // DETAIL: HStack with list + recipe detail
            HStack(spacing: 0) {
                // Recipe List
                List {
                    Text("Recipe 1")
                    Text("Recipe 2")
                    Text("Recipe 3")
                }
                .frame(width: 300)

                Divider()

                // Recipe Detail
                Text("Recipe Detail Area")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    LayoutPrototypesView()
}
