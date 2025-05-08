import Foundation

protocol GetSessionUseCaseProtocol {
    func run() async throws
}

final class GetSessionUseCase: GetSessionUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.authRepository = authRepository
    }
    
    func run() async throws {
        let _ = try await authRepository.getSession()
    }
}
