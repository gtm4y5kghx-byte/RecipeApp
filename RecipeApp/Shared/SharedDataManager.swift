import Foundation

class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let appGroupIdentifier = "group.com.jasenmp.RecipeApp"
    private let pendingImportFileName = "pendingRecipeImport.json"
    
    private init() {}
    
    private var sharedContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    private var pendingImportFileURL: URL? {
        return sharedContainerURL?.appendingPathComponent(pendingImportFileName)
    }
    
    func savePendingImport(_ recipeData: RecipeImportData) throws {
        guard let fileURL = pendingImportFileURL else {
            throw SharedDataError.containerNotFound
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(recipeData)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func loadPendingImport() throws -> RecipeImportData? {
        guard let fileURL = pendingImportFileURL else {
            throw SharedDataError.containerNotFound
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(RecipeImportData.self, from: data)
    }
    
    func deletePendingImport() throws {
        guard let fileURL = pendingImportFileURL else {
            throw SharedDataError.containerNotFound
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        try FileManager.default.removeItem(at: fileURL)
    }
    
    func hasPendingImport() -> Bool {
        guard let fileURL = pendingImportFileURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}

enum SharedDataError: LocalizedError {
    case containerNotFound
    
    var errorDescription: String? {
        switch self {
        case .containerNotFound:
            return "The app group container was not found."
        }
    }
}
