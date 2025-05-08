import Foundation

protocol GetHerosUseCaseProtocol {
    func run(name: String) async throws -> [Hero]
}

final class GetHerosUseCase: GetHerosUseCaseProtocol {
    private let herosRepository: HerosRepositoryProtocol
    
    init(herosRepository: HerosRepositoryProtocol = HerosRepository.shared) {
        self.herosRepository = herosRepository
    }
    
    func run(name: String) async throws -> [Hero] {
        try await herosRepository.getAll()
    }
}
