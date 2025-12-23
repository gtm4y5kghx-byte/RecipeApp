import SwiftUI
import SwiftData

struct CookingModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CookingModeViewModel?
    @State private var showingIngredients = false
    @State private var showingSteps = false
    
    let recipe: Recipe
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    CookingModeSteps(
                        stepItems: viewModel.stepItems,
                        currentIndex: Binding(
                            get: { viewModel.currentStepIndex },
                            set: { viewModel.jumpToStep($0) }
                        )
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button {
                                    showingSteps = true
                                } label: {
                                    Label("Steps", systemImage: "list.number")
                                }
                                
                                Button {
                                    showingIngredients = true
                                } label: {
                                    Label("Ingredients", systemImage: "list.bullet")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                    .sheet(isPresented: $showingSteps) {
                        CookingModeStepsSheet(
                            stepItems: viewModel.stepItems,
                            currentIndex: viewModel.currentStepIndex,
                            onSelectStep: { index in
                                viewModel.jumpToStep(index)
                                showingSteps = false
                            },
                            onDismiss: { showingSteps = false }
                        )
                    }
                    .sheet(isPresented: $showingIngredients) {
                        CookingModeIngredientsSheet(
                            ingredients: viewModel.ingredients,
                            onDismiss: { showingIngredients = false }
                        )
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
            }
        }
    }
}

#Preview {
    CookingModeView(recipe: SampleData.createChickenStirFry())
}
