import XCTest
@testable import DBAsynchronousiOS

final class MockAuthRepository: AuthRepositoryProtocol {
    var receivedData: Data? = nil
    
    func login(user: String, password: String) async throws {
        guard receivedData != nil else  {
            throw PresentationError.session("Failed to save session, try again")
        }
    }
    
    func getSession() async throws -> String {
        guard let receivedData else {
            throw PresentationError.session("Session not found or expired, log in again")
        }
        return receivedData.base64EncodedString()
    }
    
    func clearSession() async throws {
        // Feature not available
    }
}
