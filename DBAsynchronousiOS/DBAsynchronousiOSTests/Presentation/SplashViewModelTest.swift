import XCTest
import Combine
@testable import DBAsynchronousiOS

final class SplashViewModelTest: XCTestCase {
    var sut: SplashViewModel!
    var mockGetSessionUseCase: MockGetSessionUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetSessionUseCase = MockGetSessionUseCase()
        sut = SplashViewModel(getSessionUseCase: mockGetSessionUseCase)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockGetSessionUseCase = nil
        try super.tearDownWithError()
    }
    
    func testSplash_WhenStateIsLogin() async throws {
        // Given
        var subscription = Set<AnyCancellable>()
        let loadingExpectation = expectation(description: "Loading Succeed")
        let loginExpectation = expectation(description: "Login Succeed")
        
        // When
        sut.$state
            .sink { splashState in
                switch splashState {
                case .loading:
                    loadingExpectation.fulfill()
                case .home:
                    XCTFail("Waiting for login")
                case .login:
                    loginExpectation.fulfill()
                }
            }.store(in: &subscription)
        sut.load()
        
        // Then
        await fulfillment(of: [loadingExpectation, loginExpectation], timeout: 5)
    }
    
    func testSplash_WhenStateIsHome() async throws {
        // Given
        var subscription = Set<AnyCancellable>()
        let loadingExpectation = expectation(description: "Loading Succeed")
        let homeExpectation = expectation(description: "Login Succeed")
        let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "jwt", withExtension: "txt"))
        let jwtData = try XCTUnwrap(Data(contentsOf: fileURL))
        mockGetSessionUseCase.receivedResponse = jwtData
        
        // When
        sut.$state
            .sink { splashState in
                switch splashState {
                case .loading:
                    loadingExpectation.fulfill()
                case .home:
                    homeExpectation.fulfill()
                case .login:
                    XCTFail("Waiting for home")
                }
            }.store(in: &subscription)
        sut.load()
        
        // Then
        await fulfillment(of: [loadingExpectation, homeExpectation], timeout: 5)
    }
}
