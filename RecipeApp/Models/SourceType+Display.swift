import Foundation

extension SourceType {
    var displayName: String {
        switch self {
        case .manual: return "Manual Entry"
        case .web_imported: return "Web Import"
        case .spoonacular: return "Spoonacular"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "pencil"
        case .web_imported: return "cloud.fill"
        case .spoonacular: return "fork.knife.circle"
        }
    }
}
