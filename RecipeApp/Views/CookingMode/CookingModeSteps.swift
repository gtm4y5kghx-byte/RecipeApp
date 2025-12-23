import SwiftUI

struct CookingModeSteps: View {
    let stepItems: [CookingModeViewModel.StepItem]
    @Binding var currentIndex: Int
    
    @State private var scrolledID: Int?
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(stepItems) { item in
                CookingModeStepCard(item: item)
                    .tag(item.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
