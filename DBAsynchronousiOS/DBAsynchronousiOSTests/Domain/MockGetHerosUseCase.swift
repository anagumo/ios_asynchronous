import XCTest
@testable import DBAsynchronousiOS

final class MockGetHerosUseCase: GetHerosUseCaseProtocol {
    var receivedResponse: [Hero]? = nil
    
    func run() async throws -> [Hero] {
        guard let heros = receivedResponse else {
            throw PresentationError.network("No data received")
        }
        
        if heros.isEmpty {
            throw PresentationError.emptyList()
        } else {
            return heros
        }
    }
}
