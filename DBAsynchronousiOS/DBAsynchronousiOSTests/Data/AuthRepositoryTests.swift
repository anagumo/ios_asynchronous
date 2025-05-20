import XCTest
import Combine
@testable import DBAsynchronousiOS

final class AuthRepositoryTests: XCTestCase {
    var sut: AuthRepositoryProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: urlSessionConfiguration)
        let mockApiSession = APISession(urlSession: mockURLSession)
        let mockAuthDataSource = MockAuthDataSource()
        sut = AuthRepository(
            apiSession: mockApiSession,
            authDataSource: mockAuthDataSource
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_WhenCredentialsAreValid_ShouldSucceed() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: AuthRepositoryTests.self).url(forResource: "jwt", withExtension: "txt"))
            let jwtData = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, jwtData)
        }
        
        // When
        let successResponse: () = try await sut.login(user: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        XCTAssertNotNil(successResponse)
    }
    
    func testLogin_WhenCredentialsAreWrong_ShouldRetunUnauthorizedError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 401))
            return (httpURLResponse, Data())
        }
        
        // When
        var loginError: APIError?
        do {
            try await sut.login(user: "regularuser@keepcoding.es", password: "regular")
        } catch let error as APIError? {
            loginError = error
        }
        
        // Then
        XCTAssertNotNil(loginError)
        XCTAssertEqual(loginError?.reason, "Wrong email or password. Please log in again.")
    }
    
    func testGetSession_WhenIsSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: AuthRepositoryTests.self).url(forResource: "jwt", withExtension: "txt"))
            let jwtData = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, jwtData)
        }
        
        // When
        try await sut.login(user: "regularuser@keepcoding.es", password: "regular")
        let jwtData = try await sut.getSession()
       
        
        // Then
        XCTAssertNotNil(jwtData)
    }
    
    func testGetSession_WhenIsError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: AuthRepositoryTests.self).url(forResource: "jwt", withExtension: "txt"))
            let jwtData = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, jwtData)
        }
        
        // When
        try await sut.login(user: "regularuser@keepcoding.es", password: "regular")
        try await sut.clearSession()
        
        var sessionError: PresentationError?
        do {
            let _ = try await sut.getSession()
        } catch let error as PresentationError? {
            sessionError = error
        }
        
        // Then
        XCTAssertNotNil(sessionError)
        XCTAssertEqual(sessionError, .session("Session not found or expired, log in again"))
    }
}
