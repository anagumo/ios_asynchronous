import Foundation

protocol ApiSessionContract {
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response
}

final class APISession: ApiSessionContract {
    static let shared = APISession()
    private let urlSession: URLSession
    private let interceptor: URLRequestInterceptor
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.interceptor = URLRequestInterceptor()
    }
    
    func request<URLRequest: URLRequestComponents>(_ request: URLRequest) async throws -> URLRequest.Response {
        var urlRequest = try URLRequestBuilder(urlRequestComponents: request).build()
        
       if request.authorized {
            try await interceptor.intercept(&urlRequest)
        }
    
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
