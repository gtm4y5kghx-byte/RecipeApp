import SwiftUI
import SwiftData

struct RecipesMenuSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let viewModel: RecipeListViewModel
    let onNewRecipe: () -> Void
    let onSettings: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    actionSection
                    
                    DSDivider(spacing: .standard)
                    
                    filtersSection
                    
                    DSDivider(spacing: .standard)
                    
                    if !viewModel.sortedTags.isEmpty {
                        tagsSection
                        DSDivider(spacing: .standard)
                    }
                    
                    settingsSection
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        DSIcon("xmark", size: .medium, color: .accent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            DSLabel("ACTIONS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)
            
            DSButton(
                title: "New Recipe",
                style: .primary,
                icon: "plus"
            ) {
                dismiss()
                onNewRecipe()
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSLabel("FILTERS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)
            
            ForEach(RecipeListViewModel.filterSections) { section in
                FilterRow(
                    title: section.title,
                    icon: section.icon,
                    count: viewModel.recipeCount(for: section)
                ) {
                    dismiss()
                    viewModel.selectedSection = section
                }
            }
        }
    }
    
    private var tagsSection: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            DSLabel("TAGS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)

            ForEach(viewModel.sortedTags, id: \.0) { tag, count in
                let section = MenuSection.tag(tag)
                FilterRow(
                    title: section.title,
                    icon: section.icon,
                    count: count
                ) {
                    dismiss()
                    viewModel.selectedSection = section
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterRow(title: "Settings", icon: "gear") {
                dismiss()
                onSettings()
            }
        }
    }
}
