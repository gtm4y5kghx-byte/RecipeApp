import Speech
import AVFoundation

@Observable
class SpeechTranscriber {
    var transcript = ""
    var isTranscribing = false

    private var speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isStopped = false

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startTranscribing() throws {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechTranscriberError.recognizerUnavailable
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        isStopped = false

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechTranscriberError.recognizerUnavailable
        }

        recognitionRequest.shouldReportPartialResults = true

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isTranscribing = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result, !self.isStopped {
                self.transcript = result.bestTranscription.formattedString
            }
        }
    }

    func stopTranscribing() {
        isStopped = true

        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        isTranscribing = false
    }

    func reset() {
        transcript = ""
    }
}

enum SpeechTranscriberError: LocalizedError {
    case recognizerUnavailable
    case audioEngineFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available"
        case .audioEngineFailed:
            return "Audio engine failed to start"
        case .permissionDenied:
            return "Speech recognition permission is required to transcribe recipes"
        }
    }
}
