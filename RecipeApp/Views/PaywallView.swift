import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Unlock AI Search")
                    .font(.title)
                    .bold()
                
                Text("Get intelligent recipe search powered by AI")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Subscribe Now") {
                    // TODO: Trigger purchase flow
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
