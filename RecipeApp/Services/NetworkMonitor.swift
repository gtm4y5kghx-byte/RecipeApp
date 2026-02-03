import Foundation
import Network
import Observation

@Observable
class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.recipeapp.networkmonitor")

    private init() {
        start()
    }

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
