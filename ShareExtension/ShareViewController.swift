import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    private var sharedURL: URL?
    private var recipeData: RecipeData?
    
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
        
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for item in array {
                if let type = item["@type"] as? String, type == "Recipe" {
                    return item
                } else if let types = item["@type"] as? [String], types.contains("Recipe") {
                    return item
                }
            }
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let type = json["@type"] as? String, type == "Recipe" {
                return json
            } else if let types = json["@type"] as? [String], types.contains("Recipe") {
                return json
            }
        }
        
        return nil
    }
    
    private func parseRecipeData(from jsonLD: [String: Any]) -> RecipeData {
        let title = jsonLD["name"] as? String ?? "Untitled Recipe"
        
        var ingredients: [String] = []
        if let ingredientStrings = jsonLD["recipeIngredient"] as? [String] {
            ingredients = ingredientStrings
        } else if let ingredientObjects = jsonLD["recipeIngredient"] as? [[String: Any]] {
            ingredients = ingredientObjects.compactMap { $0["text"] as? String }
        } else if let singleString = jsonLD["recipeIngredient"] as? String {
            ingredients = [singleString]
        }
        
        var instructions: [String] = []
        if let instructionStrings = jsonLD["recipeInstructions"] as? [String] {
            instructions = instructionStrings
        } else if let instructionObjects = jsonLD["recipeInstructions"] as? [[String: Any]] {
            instructions = instructionObjects.compactMap { $0["text"] as? String }
        } else if let singleString = jsonLD["recipeInstructions"] as? String {
            instructions = [singleString]
        }
        
        return RecipeData(
            title: title,
            ingredients: ingredients,
            instructions: instructions
        )
    }
    
    private func showPreviewUI() {
        containerStackView.removeFromSuperview()
        
        let titleLabel = UILabel()
        titleLabel.text = recipeData?.title ?? "No Title"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        navItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addToAppTapped)
        )
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
    
    struct RecipeData {
        let title: String
        let ingredients: [String]
        let instructions: [String]
    }
}
