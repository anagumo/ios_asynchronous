import Foundation

protocol GetHeroUseCaseProtocol {
    func run(name: String) async throws -> Hero
}

final class GetHeroUseCase: GetHeroUseCaseProtocol {
    private let herosRepository: HerosRepositoryProtocol
    
    init(herosRepository: HerosRepositoryProtocol = HerosRepository.shared) {
        self.herosRepository = herosRepository
    }
    
    func run(name: String) async throws -> Hero {
        try await herosRepository.get(name: name)
    }
}
