import XCTest
import Combine
@testable import DBAsynchronousiOS

final class HeroViewModelTests: XCTestCase {
    var sut: HeroViewModel!
    var mockGetHeroUseCase: MockGetHeroUseCase!
    var mockGetTransformationsUseCase: MockGetTransformationsUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetHeroUseCase = MockGetHeroUseCase()
        mockGetTransformationsUseCase = MockGetTransformationsUseCase()
        sut = HeroViewModel(
            name: "Piccolo",
            getHeroUseCase: mockGetHeroUseCase,
            getTransformationsUseCase: mockGetTransformationsUseCase,
            appState: AppState()
        )
        let hero = try XCTUnwrap(HeroData.givenDomainList.filter { $0.name == "Piccolo" }.first)
        mockGetHeroUseCase.receivedResponse = hero
        mockGetTransformationsUseCase.receivedResponse = []
    }
    
    override func tearDownWithError() throws {
        mockGetHeroUseCase = nil
        mockGetTransformationsUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoad_WhenIsSuccess() async throws {
        // Given
        let successExpectation = expectation(description: "Hero succeed")
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.$hero
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { hero in
                successExpectation.fulfill()
            }.store(in: &subscriptions)
        sut.load()
        
        // Then
        await fulfillment(of: [successExpectation], timeout: 0.1)
        let piccolo = try XCTUnwrap(sut.hero)
        XCTAssertNotNil(sut.hero)
        XCTAssertEqual(sut.transformations, [])
        XCTAssertEqual(piccolo.name, "Piccolo")
    }
    
    func testLoad_WhenIsError() async throws {
        // Given
        let failureExpectation = expectation(description: "Error succeed")
        var subscriptions = Set<AnyCancellable>()
        mockGetHeroUseCase.receivedResponse = nil
        
        // When
        sut.appState.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { error in
                failureExpectation.fulfill()
            }.store(in: &subscriptions)
        sut.load()
        
        // Then
        await fulfillment(of: [failureExpectation])
        let error = try XCTUnwrap(sut.appState.error)
        XCTAssertEqual(error, "Entity not found")
        XCTAssertNil(sut.hero)
    }
    
    func testLoadTransformations_WhenAreSuccess() async throws {
        // Given
        let heroExpectation = expectation(description: "Hero succeed")
        let transformationsExpectation = expectation(description: "Transformations succeed")
        let hero = try XCTUnwrap(HeroData.givenDomainList.filter { $0.name == "Goku" }.first)
        mockGetHeroUseCase.receivedResponse = hero
        let transformations = TransformationData.givenDomainList
        mockGetTransformationsUseCase.receivedResponse = transformations
        var subscriptions = Set<AnyCancellable>()
        
        // When
        sut.$hero
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { hero in
                heroExpectation.fulfill()
            }.store(in: &subscriptions)
        
        sut.load()
        
        sut.$transformations
            .first { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { transformations in
                transformationsExpectation.fulfill()
            }.store(in: &subscriptions)
        
        sut.loadTransformations()
        
        // Then
        await fulfillment(of: [heroExpectation, transformationsExpectation], timeout: 0.1)
        XCTAssertNotNil(sut.hero)
        XCTAssertEqual(sut.transformations.count, 3)
    }
}
