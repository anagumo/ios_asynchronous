import Foundation

protocol HerosRepositoryProtocol {
    func getAll() async throws -> [Hero]
}

final class HerosRepository: HerosRepositoryProtocol {
    static let shared = HerosRepository()
    private let apiSession: ApiSessionContract
    
    init(apiSession: APISession = APISession.shared) {
        self.apiSession = apiSession
    }
    func getAll() async throws -> [Hero] {
        let heros = try await apiSession.request(
            GetHerosURLRequest(name: "")
        )
        
        guard !heros.isEmpty else {
            throw PresentationError.emptyList()
        }
        
        return heros.map {
            HeroDTOtoDomainMapper().map($0)
        }
    }
}
