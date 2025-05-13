import Foundation

protocol GetHerosUseCaseProtocol {
    func run() async throws -> [Hero]
}

final class GetHerosUseCase: GetHerosUseCaseProtocol {
    private let herosRepository: HerosRepositoryProtocol
    
    init(herosRepository: HerosRepositoryProtocol = HerosRepository.shared) {
        self.herosRepository = herosRepository
    }
    
    func run() async throws -> [Hero] {
        try await herosRepository.getAll()
    }
}
