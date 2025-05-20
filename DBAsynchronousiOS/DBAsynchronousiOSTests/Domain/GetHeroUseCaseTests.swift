import XCTest
import Combine
@testable import DBAsynchronousiOS

final class GetHeroUseCaseTests: XCTestCase {
    var sut: GetHeroUseCase!
    var mockHerosRepository: MockHerosRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockHerosRepository = MockHerosRepository()
        sut = GetHeroUseCase(herosRepository: mockHerosRepository)
    }
    
    override func tearDownWithError() throws {
        mockHerosRepository = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetHero_WhenIsSuccess() async throws {
        // Given
        let data = try XCTUnwrap(HeroData.givenDomainList)
        mockHerosRepository.receivedData = data
        
        // When
        let hero = try await sut.run(name: "Goku")
        
        // Then
        let unwrapedHero = try XCTUnwrap(hero)
        XCTAssertEqual(unwrapedHero.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        XCTAssertEqual(unwrapedHero.name, "Goku")
        XCTAssertEqual(unwrapedHero.info, "Sobran las presentaciones cuando se habla de Goku.")
        XCTAssertEqual(unwrapedHero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")
        XCTAssertEqual(unwrapedHero.favorite, false)
    }
    
    func testGetHero_WhenAreEmptyError() async throws {
        // Given
        mockHerosRepository.receivedData = []
        
        // When
        var heroError: PresentationError?
        do {
            let _ = try await sut.run(name: "Gohan:(")
        } catch let error as PresentationError {
            heroError = error
        }
        
        // Then
        XCTAssertNotNil(heroError)
        XCTAssertEqual(heroError?.reason, "Entity not found")
    }
}
