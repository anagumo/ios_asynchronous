import Foundation

protocol LoginUseCaseProtocol {
    func run(user: String?, password: String?) async throws
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func run(user: String?, password: String?) async throws {
        let user = try RegexLint.validate(data: user, matchWith: .email)
        let password = try RegexLint.validate(data: password, matchWith: .password)
        try await authRepository.login(user: user, password: password)
    }
}
