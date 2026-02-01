import Foundation

enum AppConstants {
    static let privacyPolicyURL = URL(string: "https://yourapp.com/privacy")!
    static let termsOfServiceURL = URL(string: "https://yourapp.com/terms")!
    static let supportEmail = "support@yourapp.com"

    static var supportEmailURL: URL {
        URL(string: "mailto:\(supportEmail)")!
    }

    static let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }()
}
