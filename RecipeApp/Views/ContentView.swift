import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingUnavailableAlert = false
    @State private var unavailabilityMessage: String?
    @AppStorage("hasShownAIUnavailableAlert") private var hasShownAlert = false

    var body: some View {
        RecipeListView()
            .onAppear() {
                checkFoundationModelsAvailability()
            }
            .alert("AI Features Unavailable", isPresented: $showingUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(unavailabilityMessage ?? "AI features are currently unavailable.")
            }
    }
    
    private func checkFoundationModelsAvailability() {
        guard !hasShownAlert else { return }
        
        if let reason = FoundationModelsService.unavailabilityReason {
            unavailabilityMessage = reason
            showingUnavailableAlert = true
            hasShownAlert = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
