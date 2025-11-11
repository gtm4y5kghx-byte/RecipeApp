import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var animationAmount: CGFloat = 1.0
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
    }
    
    private var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleRecording() {
        if isRecording {
            audioRecorder.stopRecording()
            stopTimer()
            isRecording = false
        } else {
            Task {
                do {
                    try await audioRecorder.startRecording()
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
}
