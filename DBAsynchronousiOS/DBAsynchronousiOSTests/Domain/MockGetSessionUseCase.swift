import XCTest
@testable import DBAsynchronousiOS

final class MockGetSessionUseCase: GetSessionUseCaseProtocol {
    var receivedResponse: Data? = nil
    
    func run() async throws {
        guard let _ = receivedResponse else {
            throw PresentationError.session("Session not found or expired, log in again")
        }
    }
}
