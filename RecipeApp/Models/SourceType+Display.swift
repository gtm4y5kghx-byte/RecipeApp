import Foundation

extension SourceType {
    var displayName: String {
        switch self {
        case .voice_created: return "Voice Recording"
        case .voice_oral_history: return "From Oral History"
        case .photo_card: return "Recipe Card"
        case .photo_cookbook: return "Cookbook"
        case .photo_process: return "Cooking Process"
        case .web_imported: return "Web Import"
        case .manual: return "Manual Entry"
        }
    }
    
    var icon: String {
        switch self {
        case .voice_created: return "mic.fill"
        case .voice_oral_history: return "book.fill"
        case .photo_card: return "photo"
        case .photo_cookbook: return "book.fill"
        case .photo_process: return "photo"
        case .web_imported: return "cloud.fill"
        case .manual: return "pencil.fill"
        }
    }
}
