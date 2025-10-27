import Foundation
import Network


// MARK: - APIServiceProtocol
protocol APIServiceProtocol: AnyObject {

    // MARK: - Methods
    func fetchUsers(
        page: Int,
        results: Int,
        seed: String?,
        retries: Int,
        delay: Double,
        completion: @escaping (Result<RandomUserResponse, NetworkError>) -> Void
    )

    func currentNetworkStatus() -> Bool
}

// MARK: - Convenience Methods
extension APIServiceProtocol {
    func fetchUsers(
        page: Int,
        seed: String?,
        completion: @escaping (Result<RandomUserResponse, NetworkError>) -> Void
    ) {
        
        /// Fetch users with default results, retries, and delay
        fetchUsers(
            page: page,
            results: 25,
            seed: seed,
            retries: 2,
            delay: 1.0,
            completion: completion
        )
    }
}

// MARK: - NetworkError
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(Int)
    case noInternet
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .noInternet:
            return "No internet connection"
        }
    }
}

// MARK: - APIService
class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let baseURL = "https://randomuser.me/api/"
    private let session: URLSession
    
    // Network Monitor
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected: Bool = true
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Start network monitoring
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: monitorQueue)
    }
    
    deinit {
        monitor.cancel() // free up monitor
    }
    
    // MARK: - Fetch Users
    func fetchUsers(
        page: Int,
        results: Int = 25,
        seed: String? = nil,
        retries: Int = 2,
        delay: Double = 1.0,
        completion: @escaping (Result<RandomUserResponse, NetworkError>) -> Void
    ) {
        
        guard isConnected else {
            completion(.failure(.noInternet))
            return
        }
        
        var components = URLComponents(string: baseURL)
        
        var queryItems = [
            URLQueryItem(name: "results", value: "\(results)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // Use seed for consistent pagination
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: seed))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🌐 Fetching users from: \(url.absoluteString)")
        
        session.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                if retries > 0 {
                    print("Network error, retrying in \(delay)s (\(retries) left)")
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self?.fetchUsers(page: page, results: results, retries: retries - 1, completion: completion)
                    }
                } else {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let randomUserResponse = try JSONDecoder().decode(RandomUserResponse.self, from: data)
                print("✅ Successfully fetched \(randomUserResponse.results.count) users")
                completion(.success(randomUserResponse))
            } catch {
                print("❌ Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Current network status
    func currentNetworkStatus() -> Bool {
        return isConnected
    }
}
