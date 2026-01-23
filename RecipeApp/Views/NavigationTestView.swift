import SwiftUI
import Swipy

/// Test view to prototype programmatic navigation with binding + Swipy swipe-to-delete
struct NavigationTestView: View {
    @State private var selectedItem: String?
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var isSwipingAnItem = false
    @State private var items: [String] = (1...50).map { "Item \($0)" }

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
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
            List {
                Text("All Items")
            }
            .navigationTitle("Folders")
        } content: {
            itemListView
                .navigationTitle("Items")
                .navigationBarTitleDisplayMode(.large)
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
                ForEach(items, id: \.self) { item in
                    Swipy(isSwipingAnItem: $isSwipingAnItem) { model in
                        ItemCard(title: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                            }
                    } actions: {
                        SwipyAction { model in
                            Button {
                                withAnimation {
                                    items.removeAll { $0 == item }
                                }
                                model.unswipe()
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.red)
                            }
                        }
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition($scrollPosition)
        .scrollDisabled(isSwipingAnItem)
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
