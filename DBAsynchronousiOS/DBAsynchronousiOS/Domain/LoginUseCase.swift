import Foundation

protocol LoginUseCaseProtocol {
    func run(user: String, password: String) async throws
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func run(user: String, password: String) async throws {
        try await authRepository.login(user: user, password: password)
    }
}
