import Foundation

protocol ApiSessionContract {
    func request<RequestComponents: URLRequestComponents>(_ request: RequestComponents) async throws -> RequestComponents.Response
}

final class ApiSession: ApiSessionContract {
    
    func request<RequestComponents: URLRequestComponents>(_ request: RequestComponents) async throws -> RequestComponents.Response {
        let urlRequest = try URLRequestBuilder(urlRequestComponents: request).build()
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode else {
            throw APIError.server(url: request.path, statusCode: statusCode)
        }
        
        switch statusCode {
        case 200..<300:
            // Validation for Login response data since is not a JSON
            if RequestComponents.Response.self == Data.self {
                return (data as! RequestComponents.Response)
            } else {
                do {
                    let response = try JSONDecoder().decode(RequestComponents.Response.self, from: data)
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
