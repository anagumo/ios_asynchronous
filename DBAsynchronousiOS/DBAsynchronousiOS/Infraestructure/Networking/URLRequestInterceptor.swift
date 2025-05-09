import Foundation

protocol URLRequestInterceptorProtocol {
    func intercept(_ request: inout URLRequest) async throws
}

final class URLRequestInterceptor: URLRequestInterceptorProtocol {
    private var authDataSource: AuthDataSource
    
    init(authDataSource: AuthDataSource = .shared) {
        self.authDataSource = authDataSource
    }
    
    func intercept(_ request: inout URLRequest) async throws {
        let jwt = try await authDataSource.get()
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
    }
}
