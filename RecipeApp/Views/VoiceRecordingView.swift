import SwiftUI
import AVFoundation
import UIKit

struct VoiceRecordingView: View {
    @Environment(\.dismiss) var dismiss
    
    enum RecordingState {
        case idle
        case recording
        case stopped
        case processing
    }
    
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var animationAmount: CGFloat = 1.0
    @State private var speechTranscriber = SpeechTranscriber()
    @State private var foundationModelsService = FoundationModelsService()
    @State private var structuredRecipe: Recipe?
    @State private var showCancelConfirmation = false
    @State private var recordingState: RecordingState = .idle
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                ZStack {
                    if recordingState == .recording {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .scaleEffect(animationAmount)
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                ) {
                                    animationAmount = 1.2
                                }
                            }
                    }
                    
                    Circle()
                        .fill(recordingState == .recording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                
                Text(formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(recordingState == .recording ? .primary : .secondary)
                
                ScrollView {
                    Text(speechTranscriber.transcript.isEmpty ? "Tap record and start speaking..." : speechTranscriber.transcript)
                        .font(.body)
                        .foregroundStyle(speechTranscriber.transcript.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if recordingState == .idle || recordingState == .recording {
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(recordingState == .recording ? Color.red : Color.blue)
                                .frame(width: 80, height: 80)
                            
                            if recordingState == .recording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                } else if recordingState == .stopped {
                    VStack(spacing: 16) {
                        Button(action: processRecipe) {
                            Text("Process Recipe")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            if !speechTranscriber.transcript.isEmpty {
                                showCancelConfirmation = true
                            } else {
                                resetToIdle()
                                dismiss()
                            }
                        }) {
                            Text("Discard")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Record Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if recordingState == .recording || recordingState == .stopped {
                            showCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .confirmationDialog("Discard Recording?", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
                Button("Discard", role: .destructive) {
                    if recordingState == .recording {
                        speechTranscriber.stopTranscribing()
                        stopTimer()
                    }

                    resetToIdle()
                    speechTranscriber.reset()

                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()

                    dismiss()
                }
                
                Button("Keep Recording", role: .cancel ) { }
            }
            .navigationDestination(item: $structuredRecipe) { recipe in
              makeRecipeFormView(for: recipe)
            }
        }
        .errorAlert($error)
        .overlay {
            if recordingState == .processing {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Processing recipe...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(Color(.systemGray6)) 
                    .cornerRadius(16)
                }
            }
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleRecording() {
        if recordingState == .recording {
            speechTranscriber.stopTranscribing()
            stopTimer()
            recordingState = .stopped

            let haptic = UIImpactFeedbackGenerator(style: .medium)
            haptic.impactOccurred()

        } else if recordingState == .idle {
            Task {
                do {
                    let speechPermission = await speechTranscriber.requestPermission()
                    guard speechPermission else {
                        throw SpeechTranscriberError.permissionDenied
                    }

                    speechTranscriber.reset()
                    try speechTranscriber.startTranscribing()

                    startTimer()
                    recordingState = .recording

                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()

                } catch {
                    let haptic = UIImpactFeedbackGenerator(style: .heavy)
                    haptic.impactOccurred()

                    self.error = error
                }
            }
        }
    }
    
    private func processRecipe() {
        guard !speechTranscriber.transcript.isEmpty else {
            error = NSError(
                domain: "RecipeApp",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No transcript available. Please record again."]
            )
            return
        }
        
        recordingState = .processing
        
        Task {
            do {
                let voiceRecipe = try await foundationModelsService.structureRecipe(from: speechTranscriber.transcript)
                
                if voiceRecipe.title.isEmpty || voiceRecipe.title.lowercased().contains("unknown") {
                     throw NSError(
                         domain: "RecipeApp",
                         code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Could not identify a recipe. Please try again with recipe details."]
                     )
                 }
                
                let recipe = createRecipe(from: voiceRecipe)
                
                recordingState = .idle
                
                try? await Task.sleep(nanoseconds: 100_000_000)
            
                structuredRecipe = recipe
                
            } catch {
                recordingState = .stopped
                
                let haptic = UIImpactFeedbackGenerator(style: .heavy)
                haptic.impactOccurred()
                
                self.error = error
            }
        }
    }
    
    private func resetToIdle() {
        recordingState = .idle
        recordingDuration = 0
    }
    
    private func makeRecipeFormView(for recipe: Recipe) -> RecipeFormView {
         RecipeFormView(recipe: recipe, onSaveFromVoiceRecording: {
             speechTranscriber.reset()
             dismiss()
         })
     }
    
    private func startTimer() {
        recordingDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func createRecipe(from voiceRecipe: VoiceRecipe) -> Recipe {
        let recipe = Recipe(title: voiceRecipe.title, sourceType: .voice_created)
        
        recipe.servings = voiceRecipe.servings
        recipe.prepTime = voiceRecipe.prepTime
        recipe.cookTime = voiceRecipe.cookTime
        recipe.cuisine = voiceRecipe.cuisine
        recipe.notes = voiceRecipe.notes
        
        if let prep = voiceRecipe.prepTime, let cook = voiceRecipe.cookTime {
            recipe.totalTime = prep + cook
        }
        
        recipe.ingredients = voiceRecipe.ingredients.enumerated().map { index, voiceIngredient in
            let ingredient = Ingredient(
                quantity: "",
                unit: nil,
                item: voiceIngredient.text,
                preparation: nil,
                section: nil
            )
            ingredient.order = index
            return ingredient
        }
        
        recipe.instructions = voiceRecipe.instructions.enumerated().map { index, voiceInstruction in
            let step = Step(instruction: voiceInstruction.text)
            step.order = index
            return step
        }
        
        return recipe
    }
}
