import Testing
@testable import RecipeApp

@Suite("String Extensions Tests")
struct StringExtensionsTests {
    
    // MARK: - Markdown Code Fence Stripping
    
    @Test("Strip markdown json code fences")
    func testStripMarkdownJsonFences() {
        let input = """
          ```json
          {"key": "value"}
          ```
          """
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "{\"key\": \"value\"}")
    }
    
    @Test("Strip generic markdown code fences")
    func testStripGenericMarkdownFences() {
        let input = """
          ```
          Some code here
          ```
          """
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "Some code here")
    }
    
    @Test("Handle string without code fences")
    func testNoCodeFences() {
        let input = "{\"key\": \"value\"}"
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "{\"key\": \"value\"}")
    }
    
    @Test("Trim whitespace after stripping")
    func testTrimWhitespace() {
        let input = """
          
          ```json
          {"key": "value"}
          ```
          
          """
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "{\"key\": \"value\"}")
    }
    
    @Test("Handle empty string")
    func testEmptyString() {
        let input = ""
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "")
    }
    
    @Test("Handle only code fences")
    func testOnlyCodeFences() {
        let input = "```json```"
        
        let result = input.strippingMarkdownCodeFences()
        
        #expect(result == "")
    }
}
