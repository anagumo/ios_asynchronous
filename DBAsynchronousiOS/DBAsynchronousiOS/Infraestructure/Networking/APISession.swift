import Foundation

protocol ApiSessionContract {
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response
}

final class APISession: ApiSessionContract {
    static let shared = APISession()
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response {
        let urlRequest = try URLRequestBuilder(urlRequestComponents: request).build()
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode else {
            throw APIError.server(url: request.path, statusCode: statusCode)
        }
        
        switch statusCode {
        case 200..<300:
            // Validation for Login response data since is not a JSON
            if URLRequest.Response.self == Data.self {
                return (data as! URLRequest.Response)
            } else {
                do {
                    let response = try JSONDecoder().decode(URLRequest.Response.self, from: data)
                    return response
                } catch {
                    throw APIError.decoding(url: request.path)
                }
            }
        case 401:
            // Represents an unauthorized error to provide feedback about wrong email or password
            throw APIError.unauthorized(url: request.path, statusCode: statusCode)
        default:
            throw APIError.server(url: request.path, statusCode: statusCode)
        }
    }
}
