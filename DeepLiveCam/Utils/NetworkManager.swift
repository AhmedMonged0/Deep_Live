import Foundation
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var isConnected = false
    @Published var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(from: path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    // MARK: - Network Requests
    
    func makeRequest<T: Codable>(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard isConnected else {
            completion(.failure(.noConnection))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Download Manager
    
    func downloadFile(
        from url: URL,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        guard isConnected else {
            completion(.failure(.noConnection))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(localURL))
        }
        
        // Monitor progress
        let observation = task.progress.observe(\.fractionCompleted) { progressValue, _ in
            DispatchQueue.main.async {
                progress(progressValue.fractionCompleted)
            }
        }
        
        task.resume()
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case noConnection
    case requestFailed(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct UpdateInfo: Codable {
    let version: String
    let build: String
    let releaseNotes: String
    let downloadURL: String
    let isRequired: Bool
}

// MARK: - App Update Manager

class AppUpdateManager: ObservableObject {
    @Published var updateAvailable = false
    @Published var updateInfo: UpdateInfo?
    @Published var isCheckingForUpdates = false
    
    private let networkManager = NetworkManager.shared
    
    func checkForUpdates() {
        guard networkManager.isConnected else { return }
        
        isCheckingForUpdates = true
        
        // This would be your actual API endpoint
        let url = URL(string: "https://api.deeplivecam.app/updates/latest")!
        
        networkManager.makeRequest(
            url: url,
            method: .GET,
            responseType: APIResponse<UpdateInfo>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCheckingForUpdates = false
                
                switch result {
                case .success(let response):
                    if response.success, let updateInfo = response.data {
                        self?.updateInfo = updateInfo
                        self?.updateAvailable = true
                    }
                case .failure(let error):
                    print("Update check failed: \(error)")
                }
            }
        }
    }
    
    func downloadUpdate() {
        guard let updateInfo = updateInfo else { return }
        
        // Implement update download logic
        print("Downloading update: \(updateInfo.version)")
    }
}
