import XCTest
@testable import DBAsynchronousiOS

final class MockGetHeroUseCase: GetHeroUseCaseProtocol {
    var receivedResponse: Hero? = nil
    
    func run(name: String) async throws -> Hero {
        guard let hero = receivedResponse else {
            throw PresentationError.notFound()
        }
        
        return hero
    }
}
