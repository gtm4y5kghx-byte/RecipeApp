import Foundation

extension SourceType {
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .web_imported: return "Web Import"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .web_imported: return "cloud.fill"
        }
    }
}
