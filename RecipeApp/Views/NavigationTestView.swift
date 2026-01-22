import SwiftUI

/// Test view to validate NavigationSplitView three-column selection pattern
/// Based on Swift with Majid example
struct NavigationTestView: View {
    @State private var selectedFolder: String?
    @State private var selectedItem: String?

    @State private var folders = [
        "All": ["Item1", "Item2", "Item3"],
        "Favorites": ["Item2", "Item3"],
        "Recent": ["Item1"]
    ]

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedFolder) {
                ForEach(Array(folders.keys.sorted()), id: \.self) { folder in
                    NavigationLink(value: folder) {
                        Text(verbatim: folder)
                    }
                }
            }
            .navigationTitle("Sidebar")
        } content: {
            if let selectedFolder {
                List(selection: $selectedItem) {
                    ForEach(folders[selectedFolder, default: []], id: \.self) { item in
                        NavigationLink(value: item) {
                            Text(verbatim: item)
                        }
                    }
                }
                .navigationTitle(selectedFolder)
                .navigationBarTitleDisplayMode(.large)
            } else {
                ContentUnavailableView("Select a Folder", systemImage: "folder")
            }
        } detail: {
            if let selectedItem {
                Text("Detail for: \(selectedItem)")
                    .font(.largeTitle)
                    .navigationTitle(selectedItem)
            } else {
                ContentUnavailableView("Select an Item", systemImage: "doc")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    NavigationTestView()
}
