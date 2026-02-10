import Foundation
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case none

        var displayName: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Mobil Data"
            case .ethernet: return "Ethernet"
            case .none: return "İnternet Yoxdur"
            }
        }
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .none
        }
    }

    deinit {
        monitor.cancel()
    }
}

// Connection status view
import SwiftUI

struct NetworkStatusBar: View {
    @ObservedObject var monitor = NetworkMonitor.shared

    var body: some View {
        if !monitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)

                Text("İnternet əlaqəsi yoxdur")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(Color.red)
            .transition(.move(edge: .top))
        }
    }
}
