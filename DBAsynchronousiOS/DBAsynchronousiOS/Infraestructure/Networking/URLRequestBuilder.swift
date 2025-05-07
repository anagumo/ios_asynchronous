import Foundation

final class URLRequestBuilder {
    private let URLRequestComponents: any URLRequestComponents
    
    init(urlRequestComponents: any URLRequestComponents) {
        self.URLRequestComponents = urlRequestComponents
    }
    
    private func url() throws -> URL {
        var urlComponents: URLComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = URLRequestComponents.host
        urlComponents.path = URLRequestComponents.path
        
        if let queryParameters = URLRequestComponents.queryParameters, !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw APIError.malformedURL(url: URLRequestComponents.path)
        }
        
        return url
    }
    
    func build() throws -> URLRequest {
        do {
            var urlRequest = try URLRequest(url: url())
            urlRequest.httpMethod = URLRequestComponents.httpMethod.rawValue
            urlRequest.allHTTPHeaderFields = [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json"
            ].merging(URLRequestComponents.headers) { $1 }
            
            if let body = URLRequestComponents.body {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            }
            
            return urlRequest
        } catch {
            throw APIError.badRequest(url: URLRequestComponents.path)
        }
    }
}
