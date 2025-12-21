import Foundation

extension SourceType {
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .web_imported: return "Web Import"
        case .ai_generated: return "AI Generated"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .web_imported: return "cloud.fill"
        case .ai_generated: return "sparkles"
        }
    }
}
