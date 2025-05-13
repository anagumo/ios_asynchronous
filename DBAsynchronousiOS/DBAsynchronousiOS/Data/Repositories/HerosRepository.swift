import Foundation

protocol HerosRepositoryProtocol {
    func getAll() async throws -> [Hero]
    func get(name: String) async throws -> Hero
}

final class HerosRepository: HerosRepositoryProtocol {
    static let shared = HerosRepository()
    private let apiSession: ApiSessionContract
    
    init(apiSession: APISession = APISession.shared) {
        self.apiSession = apiSession
    }
    
    func getAll() async throws -> [Hero] {
        let heroDTOList = try await apiSession.request(
            GetHerosURLRequest()
        )
        
        guard !heroDTOList.isEmpty else {
            throw PresentationError.emptyList()
        }
        
        return heroDTOList.map {
            HeroDTOtoDomainMapper().map($0)
        }
    }
    
    func get(name: String) async throws -> Hero {
        let heroDTO = try await apiSession.request(
            GetHerosURLRequest(name: name)
        ).first
        
        guard let heroDTO else {
            throw PresentationError.notFound()
        }
        
        return HeroDTOtoDomainMapper().map(heroDTO)
    }
}
