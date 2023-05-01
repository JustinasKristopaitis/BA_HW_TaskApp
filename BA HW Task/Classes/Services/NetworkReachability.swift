import Network
import Foundation

// Taken just from internet :) There is no logic from me
enum NetworkStatus {
    case connected
    case disconnected
}

class NetworkReachability: ObservableObject {
    private let monitor = NWPathMonitor()
    
    @Published var status: NetworkStatus = .disconnected
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.status = .connected
                } else {
                    self?.status = .disconnected
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkReachability")
        monitor.start(queue: queue)
    }
}
