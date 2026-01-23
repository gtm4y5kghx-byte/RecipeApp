import SwiftUI

private struct IsIPadKey: EnvironmentKey {
    static let defaultValue: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension EnvironmentValues {
    var isIPad: Bool {
        get { self[IsIPadKey.self] }
        set { self[IsIPadKey.self] = newValue }
    }
}
