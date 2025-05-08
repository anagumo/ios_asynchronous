import Foundation

protocol URLRequestInterceptorProtocol {
    func intercept(_ request: inout URLRequest) async throws
}

final class URLRequestInterceptor: URLRequestInterceptorProtocol {
    private var authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.authRepository = authRepository
    }
    
    func intercept(_ request: inout URLRequest) async throws {
        let jwt = try await authRepository.getSession()
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
    }
}
