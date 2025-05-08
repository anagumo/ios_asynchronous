import Foundation

protocol ClearSessionUseCaseProtocol {
    func run() async throws
}

final class ClearSessionUseCase: GetSessionUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.authRepository = authRepository
    }
    
    func run() async throws {
        try await authRepository.clearSession()
    }
}
