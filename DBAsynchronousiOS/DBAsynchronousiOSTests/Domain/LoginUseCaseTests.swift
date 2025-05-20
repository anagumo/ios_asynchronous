import XCTest
@testable import DBAsynchronousiOS

final class LoginUseCaseTests: XCTestCase {
    var sut: LoginUseCaseProtocol!
    var mockAuthRepository: MockAuthRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthRepository = MockAuthRepository()
        sut = LoginUseCase(authRepository: mockAuthRepository)
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_WhenCredentialsAreValid_ShouldSucceed() async throws {
        // Given
        let fileURL = try XCTUnwrap(Bundle(for: LoginUseCaseTests.self).url(forResource: "jwt", withExtension: "txt"))
        let data = try XCTUnwrap(Data(contentsOf: fileURL))
        mockAuthRepository.receivedData = data
        
        // When
        let successResponse: () = try await sut.run(user: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        XCTAssertNotNil(successResponse)
    }
    
    func testLogin_WhenCredentialsAreInvalid_ShouldReturnRegexError() async throws {
        // When
        var loginError: RegexLintError?
        do {
            let _ = try await sut.run(user: "regularuser", password: "Regularuser1")
        } catch let error as RegexLintError {
            loginError = error
        }
        
        // Then
        XCTAssertNotNil(loginError)
        XCTAssertEqual(loginError, .email)
    }
    
    func testLogin_WhenCredentialsAreWrong_ShouldRetunUnauthorizedError() async throws {
        // When
        var loginError: PresentationError?
        do {
            let _ = try await sut.run(user: "regularuser@keepcoding.es", password: "Regularuser13")
        } catch let error as PresentationError {
            loginError = error
        }
        
        // Then
        XCTAssertNotNil(loginError)
        XCTAssertEqual(loginError?.reason, "Failed to save session, try again")
    }
}
