import UIKit
import SwiftUI
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: UIViewController {

    private var viewModel: ShareViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ShareViewModel(
            dismiss: { [weak self] in
                self?.extensionContext?.cancelRequest(
                    withError: NSError(domain: "RecipeApp", code: 0)
                )
            },
            complete: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil)
            }
        )

        let hostingController = UIHostingController(
            rootView: SharePreviewView(viewModel: viewModel)
        )

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        hostingController.didMove(toParent: self)

        extractURLAndLoad()
    }

    private func extractURLAndLoad() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            viewModel.state = .error(title: "Import Failed", message: "No URL found")
            return
        }

        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, error in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            Task { await self?.viewModel.loadRecipe(from: url) }
                        } else {
                            self?.viewModel.state = .error(
                                title: "Import Failed",
                                message: error?.localizedDescription ?? "Could not load URL"
                            )
                        }
                    }
                }
                return
            }
        }

        viewModel.state = .error(title: "Import Failed", message: "No URL found")
    }
}
