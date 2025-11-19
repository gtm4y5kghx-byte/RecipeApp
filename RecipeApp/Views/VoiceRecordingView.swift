import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var animationAmount: CGFloat = 1.0
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var apiService = RecipeAPIService()
    @State private var isProcessing = false
    @State private var structuredRecipe: Recipe?
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                ZStack {
                    if isRecording {
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
                        .fill(isRecording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                
                Text(formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(isRecording ? .primary : .secondary)
                
                ScrollView {
                    Text(speechRecognizer.transcript.isEmpty ? "Tap record and start speaking..." : speechRecognizer.transcript)
                        .font(.body)
                        .foregroundStyle(speechRecognizer.transcript.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                        
                        if isRecording {
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
            }
            .padding()
            .navigationTitle("Record Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .errorAlert($error)
        .overlay {
            if isProcessing {
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
        .navigationDestination(item: $structuredRecipe) { recipe in
            RecipeFormView(recipe: recipe)
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleRecording() {
        if isRecording {
            audioRecorder.stopRecording()
            speechRecognizer.stopTranscribing()
            stopTimer()
            isRecording = false
            processTranscript()
        } else {
            Task {
                do {
                    let speechPermission = await speechRecognizer.requestPermission()
                    guard speechPermission else {
                        throw SpeechRecognizerError.permissionDenied
                    }
                    
                    speechRecognizer.reset()
                    
                    try await audioRecorder.startRecording()
                    try speechRecognizer.startTranscribing()
                    
                    startTimer()
                    isRecording = true
                } catch {
                    self.error = error
                }
            }
        }
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
    
    private func processTranscript() {
        let transcript = speechRecognizer.transcript
        
        guard !transcript.isEmpty else {
            error = NSError(
                domain: "RecipeApp",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No transcript available. Please try recording again."]
            )
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                let response = try await apiService.structureRecipe(from: transcript)
                isProcessing = false
                
                let recipe = createRecipe(from: response)
                structuredRecipe = recipe
            } catch {
                isProcessing = false
                self.error = error
            }
        }
    }
    
    private func createRecipe(from response: RecipeResponse) -> Recipe {
        let recipe = Recipe(title: response.title, sourceType: .voice_created)
        
        recipe.servings = response.servings
        recipe.prepTime = response.prepTime
        recipe.cookTime = response.cookTime
        recipe.cuisine = response.cuisine
        recipe.notes = response.notes
        
        if let prep = response.prepTime, let cook = response.cookTime {
            recipe.totalTime = prep + cook
        }
        
        recipe.ingredients = response.ingredients.enumerated().map { index, ingredientResponse in
            let ingredient = Ingredient(
                quantity: ingredientResponse.quantity ?? "",
                unit: ingredientResponse.unit,
                item: ingredientResponse.item,
                preparation: ingredientResponse.preparation,
                section: ingredientResponse.section
            )
            ingredient.order = index
            return ingredient
        }
        
        recipe.instructions = response.instructions.map { instructionResponse in
            let step = Step(instruction: instructionResponse.instruction)
            step.order = instructionResponse.order
            return step
        }
        
        if let audioURL = audioRecorder.getRecordingURL() {
            // TODO: Convert audio file to Data and store
            // For now, just store the file path in notes
            recipe.originalAudio = nil // Will implement audio storage in Story 2.5
        }
        
        return recipe
    }
}
