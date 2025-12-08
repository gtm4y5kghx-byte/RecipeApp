import SwiftUI
import SwiftData

struct RecipeTransformationView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RecipeTransformationViewModel

    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = State(initialValue: RecipeTransformationViewModel(
            recipe: recipe,
            modelContext: ModelContext(try! ModelContainer(for: Recipe.self))
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How would you like to transform this recipe?")
                    .font(.headline)
                    .padding(.top)
                
                TextField("E.g., Make it vegan, Double the recipe, Convert to air fryer", text: $viewModel.transformationPrompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding()

                Spacer()
            }
            .navigationTitle("Transform Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Transform") {
                        Task {
                            if await viewModel.transformRecipe() {
                                HapticFeedback.success.trigger()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.transformationPrompt.isEmpty)
                }
            }
        }
        .overlay {
            if viewModel.isProcessing {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Transforming recipe...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
        }
        .onAppear {
            viewModel = RecipeTransformationViewModel(
                recipe: recipe,
                modelContext: modelContext
            )
        }
        .errorAlert($viewModel.error)
    }
}
