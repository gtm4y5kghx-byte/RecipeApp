
import AVFoundation
import SwiftUI

@Observable
class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var isRecording = false
    private var audioRecorder: AVAudioRecorder?
    private var audioFilename: URL?
    
    func startRecording() async throws {
        let permissionGranted = await AVAudioApplication.requestRecordPermission()
        guard permissionGranted else {
            throw RecordingError.permissionDenied
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        
        let filename = "recording-\(Date().timeIntervalSince1970).m4a"
        audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        isRecording = true
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func getRecordingURL() -> URL? {
        return audioFilename
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

enum RecordingError: LocalizedError {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission is required to record audio"
        }
    }
}
