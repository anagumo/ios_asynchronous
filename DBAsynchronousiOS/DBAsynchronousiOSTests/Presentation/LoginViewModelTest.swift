import XCTest
import Combine
@testable import DBAsynchronousiOS

final class LoginViewModelTest: XCTestCase {
    var sut: LoginViewModel!
    var mockLoginUseCase: MockLoginUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockLoginUseCase = MockLoginUseCase()
        sut = LoginViewModel(
            loginUseCase: mockLoginUseCase,
            appState: AppState()
        )
    }
    
    override func tearDownWithError() throws {
        mockLoginUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_WhenStateIsLogged() async {
        // Given
        let loggedExpectation = expectation(description: "Logged state succeed")
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.appState.$logged
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { logged in
                if logged {
                    loggedExpectation.fulfill()
                } else {
                    XCTFail("Waiting for logged state")
                }
            }.store(in: &subscriptions)
        
        sut.login(user: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        await fulfillment(of: [loggedExpectation], timeout: 0.1)
    }
    
    func testLogin_WhenStateIsFullScreenError() {
        // Given
        let failureExpectation = expectation(description: "Full screen error state succeed")
        mockLoginUseCase.receivedError = APIError(
            url: "/api/auth/login",
            reason: "Wrong email or password. Please log in again."
        )
        var subscriptions = Set<AnyCancellable>()
        
        // When
        var receivedError: String?
        sut.appState.$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { error in
                receivedError = error
                failureExpectation.fulfill()
            }.store(in: &subscriptions)
            
        sut.login(user: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, "Wrong email or password. Please log in again.")
    }
    
    func testLogin_WhenStateIsInlineScreenError() {
        // Given
        let failureExpectation = expectation(description: "Inline screen error state succeed")
        mockLoginUseCase.receivedRegexError = RegexLintError.email
        var subscriptions = Set<AnyCancellable>()
        
        // When
        var receivedError: RegexLintError?
        sut.appState.$regexError
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { error in
                receivedError = error
                failureExpectation.fulfill()
            }.store(in: &subscriptions)
            
        sut.login(user: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .email)
        XCTAssertEqual(receivedError?.localizedDescription, "Email format is invalid")
    }
}
