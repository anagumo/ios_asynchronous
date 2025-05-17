import Foundation

protocol HerosRepositoryProtocol {
    func getAll() async throws -> [Hero]
    func get(name: String) async throws -> Hero
    func getTransformations(heroIdentifier: String) async throws -> [Transformation]
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
    
    func getTransformations(heroIdentifier: String) async throws -> [Transformation] {
        let transformationDTOList = try await apiSession.request(
            GetTransformationsURLRequest(heroIdentifier: heroIdentifier)
        )
        
        guard !transformationDTOList.isEmpty else {
            throw PresentationError.emptyList()
        }
        
        return transformationDTOList.map {
            TransformationDTOtoDomainMapper().map($0)
        }
    }
}
