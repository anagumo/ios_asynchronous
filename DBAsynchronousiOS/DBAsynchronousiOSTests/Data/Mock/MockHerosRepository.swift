import XCTest
import Combine
@testable import DBAsynchronousiOS

final class MockHerosRepository: HerosRepositoryProtocol {
    var receivedData: [Hero]? = nil
    
    func getAll() async throws -> [Hero] {
        guard let receivedData else {
            throw PresentationError.network("No data received")
        }
        
        guard !receivedData.isEmpty else {
            throw PresentationError.emptyList()
        }
        
        return receivedData
    }
    
    func get(name: String) async throws -> Hero {
        guard let receivedData = receivedData?.first else {
            throw PresentationError.notFound()
        }
        
        return receivedData
    }
    
    func getTransformations(heroIdentifier: String) async throws -> [Transformation] {
        // No mock available
        []
    }
}
