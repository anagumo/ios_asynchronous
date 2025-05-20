import XCTest
import Combine
@testable import DBAsynchronousiOS

final class HerosViewModelTests: XCTestCase {
    var sut: HerosViewModel!
    var mockGetHerosUseCase: MockGetHerosUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetHerosUseCase = MockGetHerosUseCase()
        sut = HerosViewModel(
            getHerosUseCase: mockGetHerosUseCase,
            appState: AppState()
        )
    }
    
    override func tearDownWithError() throws {
        mockGetHerosUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadHeros_WhenIsSuccess() async throws {
        // Given
        let successExpectation = expectation(description: "Success state succeed")
        let heroDTOList = HeroData.givenDTOList
        let heroList = heroDTOList.compactMap { HeroDTOtoDomainMapper().map($0) }
        mockGetHerosUseCase.receivedResponse = heroList
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.$heros
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { heros in
                successExpectation.fulfill()
            }.store(in: &subscriptions)
        sut.load()
        
        // Then
        await fulfillment(of: [successExpectation], timeout: 0.1)
        XCTAssert(!sut.heros.isEmpty)
        XCTAssertEqual(sut.heros.count, 5)
        let hero = try XCTUnwrap(sut.get(by: 0))
        XCTAssertEqual(hero, "Goku")
    }
    
    func testLoadHeros_WhenIsError() async throws {
        // Given
        let failureExpectation = expectation(description: "Error state succeed")
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.appState.$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { error in
                failureExpectation.fulfill()
            }.store(in: &subscriptions)
        sut.load()
        
        // Then
        await fulfillment(of: [failureExpectation], timeout: 0.1)
        let error = try XCTUnwrap(sut.appState.error)
        XCTAssertEqual(error, "No data received")
        XCTAssert(sut.heros.isEmpty)
        XCTAssertEqual(sut.heros.count, 0)
        XCTAssertNil(sut.get(by: 0))
    }
    
    func testLoadHeros_WhenIsEmptyError() async throws {
        // Given
        let failureExpectation = expectation(description: "Error state succeed")
        mockGetHerosUseCase.receivedResponse = []
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.appState.$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { error in
                failureExpectation.fulfill()
            }.store(in: &subscriptions)
        sut.load()
        
        // Then
        await fulfillment(of: [failureExpectation], timeout: 0.1)
        let error = try XCTUnwrap(sut.appState.error)
        XCTAssertEqual(error, "Empty entity list")
        XCTAssert(sut.heros.isEmpty)
        XCTAssertEqual(sut.heros.count, 0)
        XCTAssertNil(sut.get(by: 0))
    }
}
