import Foundation

protocol GetTransformationsUseCaseProtocol {
    func run(heroIdentifier: String) async throws -> [Transformation]
}

final class GetTransformationsUseCase: GetTransformationsUseCaseProtocol {
    private let heroRepository: HerosRepositoryProtocol
    
    init(heroRepository: HerosRepositoryProtocol = HerosRepository.shared) {
        self.heroRepository = heroRepository
    }
    
    func run(heroIdentifier: String) async throws -> [Transformation] {
        try await heroRepository.getTransformations(heroIdentifier: heroIdentifier)
    }
}
