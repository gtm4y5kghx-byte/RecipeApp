import SwiftUI
import SwiftData

struct CookingModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CookingModeViewModel?
    @State private var showingIngredients = false
    @State private var showingSteps = false
    
    @State private var showingCookedConfirmation = false
    @State private var error: RecipeError?
    
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
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
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
                                
                                Divider()
                                
                                Button {
                                    if viewModel.markAsCooked() {
                                        showingCookedConfirmation = true
                                    } else {
                                        error = .saveFailed
                                    }
                                } label: {
                                    Label("Mark as Cooked", systemImage: "checkmark.circle")
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
        .alert("Marked as Cooked!", isPresented: $showingCookedConfirmation) {
            Button("OK", role: .cancel) { }
        }
        
        .alert(error?.title ?? "", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.message ?? "")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = CookingModeViewModel(
                    recipe: recipe,
                    modelContext: modelContext
                )
            }
            
            if UserDefaults.standard.object(forKey: "keepScreenOnInCookingMode") as? Bool ?? true {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

#Preview {
    CookingModeView(recipe: SampleData.createChickenStirFry())
}
