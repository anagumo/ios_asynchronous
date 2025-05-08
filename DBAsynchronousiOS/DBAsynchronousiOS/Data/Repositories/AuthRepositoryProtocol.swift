import Foundation

protocol AuthRepositoryProtocol {
    func login(user: String, password: String) async throws
    func getSession() async throws -> String
    func clearSession() async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    static let shared = AuthRepository()
    private let apiSession: ApiSessionContract
    private let authDataSource: AuthDataSourceProtocol
    
    init(apiSession: ApiSessionContract = APISession.shared,
         authDataSource: AuthDataSource = .shared) {
        self.apiSession = apiSession
        self.authDataSource = authDataSource
    }
    
    func login(user: String, password: String) async throws {
        let jwtData = try await apiSession.request(
            LoginURLRequest(user: user, password: password)
        )
        try await authDataSource.set(jwtData)
    }
    
    func getSession() async throws -> String {
        try await authDataSource.get()
    }
    
    func clearSession() async throws {
        try await authDataSource.clear()
    }
}
