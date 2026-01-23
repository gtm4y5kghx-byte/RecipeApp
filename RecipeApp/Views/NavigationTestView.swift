import SwiftUI

/// Test view to prototype programmatic navigation with binding
/// Pattern: onTapGesture sets selectedItem -> .navigationDestination(item:) triggers navigation
struct NavigationTestView: View {
    @State private var selectedFolder: String? = "All"
    @State private var selectedItem: String?
    @State private var scrollPosition = ScrollPosition(edge: .top)

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    let folders = [
        "All": (1...50).map { "Item \($0)" },
        "Favorites": (1...20).map { "Favorite \($0)" },
        "Recent": (1...10).map { "Recent \($0)" }
    ]

    var currentItems: [String] {
        folders[selectedFolder ?? "All"] ?? []
    }

    var body: some View {
        if isIPad {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (NavigationStack)

    private var iPhoneLayout: some View {
        NavigationStack {
            itemListView
                .navigationTitle("Items")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(item: $selectedItem) { item in
                    ItemDetailView(item: item)
                }
        }
    }

    // MARK: - iPad Layout (NavigationSplitView)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $selectedFolder) {
                ForEach(Array(folders.keys.sorted()), id: \.self) { folder in
                    Text(folder)
                        .tag(folder)
                }
            }
            .navigationTitle("Folders")
        } content: {
            itemListView
                .navigationTitle(selectedFolder ?? "Items")
                .navigationBarTitleDisplayMode(.large)
                .onChange(of: selectedFolder) { _, _ in
                    scrollPosition.scrollTo(edge: .top)
                }
        } detail: {
            if let selectedItem {
                ItemDetailView(item: selectedItem)
            } else {
                ContentUnavailableView("Select an Item", systemImage: "doc")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Shared Item List

    private var itemListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(currentItems, id: \.self) { item in
                    ItemCard(title: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition($scrollPosition)
    }
}

// MARK: - Item Card (simulates DSRecipeCard)

private struct ItemCard: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Item Detail View

private struct ItemDetailView: View {
    let item: String

    var body: some View {
        Text("Detail: \(item)")
            .font(.largeTitle)
            .navigationTitle(item)
    }
}

#Preview {
    NavigationTestView()
}
