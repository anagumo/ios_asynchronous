import XCTest
import Combine
@testable import DBAsynchronousiOS

final class GetHerosUseCaseTests: XCTestCase {
    var sut: GetHerosUseCase!
    var mockHerosRepository: MockHerosRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockHerosRepository = MockHerosRepository()
        sut = GetHerosUseCase(herosRepository: mockHerosRepository)
    }
    
    override func tearDownWithError() throws {
        mockHerosRepository = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetHeros_WhenIsSuccess() async throws {
        // Given
        let data = try XCTUnwrap(HeroData.givenDomainList)
        mockHerosRepository.receivedData = data
        
        // When
        let heros = try await sut.run()
        
        // Then
        XCTAssertNotNil(heros)
        XCTAssertEqual(heros.count, 5)
        let hero = try XCTUnwrap(heros.first)
        XCTAssertEqual(hero.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        XCTAssertEqual(hero.name, "Goku")
        XCTAssertEqual(hero.info, "Sobran las presentaciones cuando se habla de Goku.")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")
        XCTAssertEqual(hero.favorite, false)
    }
    
    func testGetHeros_WhenAreEmptyError() async throws {
        // Given
        mockHerosRepository.receivedData = []
        
        // When
        var herosError: PresentationError?
        do {
            let _ = try await sut.run()
        } catch let error as PresentationError {
            herosError = error
        }
        
        // Then
        XCTAssertNotNil(herosError)
        XCTAssertEqual(herosError?.reason, "Empty entity list")
    }
}
