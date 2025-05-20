import XCTest
@testable import DBAsynchronousiOS

final class MockGetTransformationsUseCase: GetTransformationsUseCaseProtocol {
    var receivedResponse: [Transformation]? = nil
    
    func run(heroIdentifier: String) async throws -> [Transformation] {
        guard let receivedResponse else {
            throw PresentationError.network("No data received")
        }
        
        if receivedResponse.isEmpty {
            throw PresentationError.emptyList()
        } else {
            return receivedResponse
        }
    }
}
