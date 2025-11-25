import Foundation

extension SourceType {
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .voice_created: return "Voice Recording"
        case .web_imported: return "Web Import"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .voice_created: return "mic.fill"
        case .web_imported: return "cloud.fill"
        }
    }
}
