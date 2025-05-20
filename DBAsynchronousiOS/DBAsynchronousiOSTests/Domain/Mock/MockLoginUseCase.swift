import XCTest
@testable import DBAsynchronousiOS

final class MockLoginUseCase: LoginUseCaseProtocol {
    var receivedError: APIError? = nil
    var receivedRegexError: RegexLintError? = nil
    
    func run(user: String?, password: String?) async throws {
        guard receivedError == nil else {
            if let receivedError {
                throw receivedError
            }
            return
        }
        
        guard receivedRegexError == nil else {
            if let receivedRegexError {
                throw receivedRegexError
            }
            return
        }
    }
}
