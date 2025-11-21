import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    private var sharedURL: URL?
    private var recipeData: RecipeImportData?
    
    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let containerStackView = UIStackView()
    
    private let customNavigationBar = UINavigationBar()
    private let navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLoadingUI()
        setupCustomNavigationBar()
        extractAndFetchRecipe()
    }
    
    private func setupLoadingUI() {
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.spacing = 16
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingSpinner.startAnimating()
        
        loadingLabel.text = "Loading Recipe..."
        loadingLabel.font = .systemFont(ofSize: 17, weight: .medium)
        loadingLabel.textColor = .secondaryLabel
        
        containerStackView.addArrangedSubview(loadingSpinner)
        containerStackView.addArrangedSubview(loadingLabel)
        
        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCustomNavigationBar() {
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navItem.title = "Recipe Preview"
        navItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        customNavigationBar.items = [navItem]
        
        view.addSubview(customNavigationBar)
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateLoadingMessage(_ message: String) {
        loadingLabel.text = message
    }
    
    private func extractAndFetchRecipe() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            showError("No URL found")
            return
        }
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) {[weak self] item, error in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            self?.sharedURL = url
                            Task {
                                await self?.fetchAndParseRecipe(from: url)
                            }
                        } else if let error = error {
                            self?.showError("Failed to load URL: \(error.localizedDescription)")
                        }
                    }
                }
                return
            }
        }
        
        showError("No URL found")
    }
    
    private func fetchAndParseRecipe(from url: URL) async {
        do {
            await MainActor.run {
                updateLoadingMessage("Fetching recipe...")
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let html = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "RecipeApp", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid HTML"])
            }
            
            await MainActor.run {
                updateLoadingMessage("Parsing recipe...")
            }
            
            guard let jsonLD = extractJSONLD(from: html) else {
                await MainActor.run {
                    showError("No recipe found on this page")
                }
                return
            }
            
            let parsedRecipe = parseRecipeData(from: jsonLD)
            
            await MainActor.run {
                self.recipeData = parsedRecipe
                self.showPreviewUI()
            }
        } catch {
            await MainActor.run {
                showError("Failed to import: \(error.localizedDescription)")
            }
        }
    }
    
    private func extractJSONLD(from html: String) -> [String: Any]? {
        let pattern = #"<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }
        
        guard let jsonRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        let jsonString = String(html[jsonRange])
        
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        if let array = jsonObject as? [[String: Any]] {
            return array.first { isRecipeType($0) }
        }
        
        if let dictionary = jsonObject as? [String: Any], isRecipeType(dictionary) {
            return dictionary
        }
        
        return nil
    }
    
    private func parseRecipeData(from jsonLD: [String: Any]) -> RecipeImportData {
        let title = jsonLD["name"] as? String ?? "Untitled Recipe"
        let ingredients = parseStringArray(from: jsonLD["recipeIngredient"])
        let instructions = parseStringArray(from: jsonLD["recipeInstructions"])
        
        let sourceURL = sharedURL?.absoluteString
        let imageURL = parseImageURL(jsonLD["image"])
        
        let prepTime = parseISODuration(jsonLD["prepTime"] as? String)
        let cookTime = parseISODuration(jsonLD["cookTime"] as? String)
        let totalTime = parseISODuration(jsonLD["totalTime"] as? String)
        
        let servings = parseServings(jsonLD["recipeYield"])
        let cuisine = parseCuisine(jsonLD["recipeCuisine"])
        let category = parseCategory(jsonLD["recipeCategory"])
        
        let author = parseAuthor(jsonLD["author"])
        let description = jsonLD["description"] as? String
        
        return RecipeImportData(
            title: title,
            description: description,
            sourceURL: sourceURL,
            imageURL: imageURL,
            prepTime: prepTime,
            cookTime: cookTime,
            totalTime: totalTime,
            servings: servings,
            cuisine: cuisine,
            category: category,
            ingredients: ingredients,
            instructions: instructions,
            author: author
        )
    }
    
    private func showPreviewUI() {
        containerStackView.removeFromSuperview()
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = recipeData?.title ?? "No Title"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let dataLabel = UILabel()
        dataLabel.numberOfLines = 0
        dataLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dataLabel.textColor = .secondaryLabel
        
        if let data = recipeData {
            var debugText = ""
            debugText += "Source: \(data.sourceURL ?? "nil")\n"
            debugText += "Description: \(data.description ?? "nil")\n"
            debugText += "Author: \(data.author ?? "nil")\n"
            debugText += "Servings: \(data.servings?.description ?? "nil")\n"
            debugText += "Prep: \(data.prepTime?.description ?? "nil") mins\n"
            debugText += "Cook: \(data.cookTime?.description ?? "nil") mins\n"
            debugText += "Total: \(data.totalTime?.description ?? "nil") mins\n"
            debugText += "Cuisine: \(data.cuisine ?? "nil")\n"
            debugText += "Category: \(data.category ?? "nil")\n"
            debugText += "Ingredients: \(data.ingredients.count)\n"
            debugText += "Instructions: \(data.instructions.count)\n"
            debugText += "Image URL: \(data.imageURL ?? "nil")\n"
            dataLabel.text = debugText
        }
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(dataLabel)
        
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        navItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addToAppTapped)
        )
    }
    
    private func isRecipeType(_ object: [String: Any]) -> Bool {
        if let type = object["@type"] as? String {
            return type == "Recipe"
        } else if let types = object["@type"] as? [String] {
            return types.contains("Recipe")
        }
        return false
    }
    
    private func parseStringArray(from value: Any?) -> [String] {
        guard let value = value else { return [] }
        
        if let strings = value as? [String] {
            return strings
        }
        
        // Handle array of objects with "text" field (e.g., HowToStep instructions)
        if let objects = value as? [[String: Any]] {
            return objects.compactMap { $0["text"] as? String }
        }
        
        // Handle single string (rare but valid per JSON-LD spec)
        if let singleString = value as? String {
            return [singleString]
        }
        
        return []
    }
    
    private func parseImageURL(_ value: Any?) -> String? {
        if let imageString = value as? String {
            return imageString
        }
        
        if let imageObject = value as? [String: Any],
           let url = imageObject["url"] as? String {
            return url
        }
        
        return nil
    }
    
    private func parseCuisine(_ value: Any?) -> String? {
        if let cuisineString = value as? String {
            return cuisineString
        }
        
        if let cuisineArray = value as? [String] {
            return cuisineArray.first
        }
        
        return nil
    }
    
    private func parseCategory(_ value: Any?) -> String? {
        if let categoryString = value as? String {
            return categoryString
        }
        
        if let categoryArray = value as? [String] {
            return categoryArray.first
        }
        
        return nil
    }
    
    private func parseISODuration(_ duration: String?) -> Int? {
        guard let duration = duration else { return nil }
        
        var totalMinutes = 0
        
        if let hoursRegex = try? NSRegularExpression(pattern: #"(\d+)H"#),
           let match = hoursRegex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)),
           let range = Range(match.range(at: 1), in: duration),
           let hours = Int(duration[range]) {
            totalMinutes += hours * 60
        }
        
        if let minutesRegex = try? NSRegularExpression(pattern: #"(\d+)M"#),
           let match = minutesRegex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)),
           let range = Range(match.range(at: 1), in: duration),
           let minutes = Int(duration[range]) {
            totalMinutes += minutes
        }
        
        return totalMinutes > 0 ? totalMinutes : nil
    }
    
    private func parseServings(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        
        if let stringValue = value as? String {
            let numbers = stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(numbers)
        }
        
        return nil
    }
    
    private func parseAuthor(_ value: Any?) -> String? {
        if let stringValue = value as? String {
            return stringValue
        }
        
        if let authorObject = value as? [String: Any],
           let name = authorObject["name"] as? String {
            return name
        }
        
        if let authorArray = value as? [[String: Any]],
           let name = authorArray.first?["name"] as? String {
            return name
        }
        
        return nil
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Import Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.extensionContext?.cancelRequest(
                withError: NSError( domain: "RecipeApp", code: 1))
        })
        
        present(alert, animated: true)
    }
    
    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(
            withError: NSError(domain: "RecipeApp", code: 0))
    }
    
    @objc private func addToAppTapped() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
