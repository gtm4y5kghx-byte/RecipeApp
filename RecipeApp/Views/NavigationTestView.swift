import SwiftUI

/// Test view to prototype ScrollView + scrollPosition
struct NavigationTestView: View {
    @State private var selectedFolder: String? = "All"
    @State private var selectedItem: String?
    @State private var scrollPosition = ScrollPosition(edge: .top)

    let folders = [
        "All": (1...50).map { "Item \($0)" },
        "Favorites": (1...20).map { "Favorite \($0)" },
        "Recent": (1...10).map { "Recent \($0)" }
    ]

    var currentItems: [String] {
        folders[selectedFolder ?? "All"] ?? []
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar - folder selection
            List(selection: $selectedFolder) {
                ForEach(Array(folders.keys.sorted()), id: \.self) { folder in
                    Text(folder)
                        .tag(folder)
                }
            }
            .navigationTitle("Folders")
        } content: {
            // Content - item list with ScrollView
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(currentItems, id: \.self) { item in
                        ItemRow(
                            title: item,
                            isSelected: selectedItem == item,
                            onTap: { selectedItem = item }
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition($scrollPosition)
            .navigationTitle(selectedFolder ?? "Items")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: selectedFolder) { _, _ in
                print("🔵 Folder changed, scrolling to top")
                scrollPosition.scrollTo(edge: .top)
            }
        } detail: {
            // Detail
            if let selectedItem {
                Text("Detail: \(selectedItem)")
                    .font(.largeTitle)
                    .navigationTitle(selectedItem)
            } else {
                ContentUnavailableView("Select an Item", systemImage: "doc")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Item Row

private struct ItemRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    NavigationTestView()
}
