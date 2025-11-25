import Foundation

struct RecipeImportData: Codable, Identifiable {
    var id = UUID()
    let title: String
    let description: String?
    let sourceURL: String?
    let imageURL: String?
    
    let prepTime: Int?
    let cookTime: Int?
    let totalTime: Int?
    
    let servings: Int?
    let cuisine: String?
    let category: String?
    
    let ingredients: [String]
    let instructions: [String]
    
    let author: String?
}
