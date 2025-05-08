import Foundation

protocol AuthRepository {
    func login(user: String, password: String) async throws
}

final class AuthRepositoryImpl: AuthRepository {
    private let apiSession: APISession
    private let authDataSource: AuthDataSourceProtocol
    
    init(apiSession: APISession = .shared,
         authDataSource: AuthDataSource = .shared) {
        self.apiSession = apiSession
        self.authDataSource = authDataSource
    }
    
    func login(user: String, password: String) async throws {
        let jwtData = try await apiSession.request(
            LoginURLRequest(user: user, password: password)
        )
        authDataSource.set(jwtData)
    }
}
