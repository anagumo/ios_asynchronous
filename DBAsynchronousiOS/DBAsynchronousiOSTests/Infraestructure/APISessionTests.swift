import XCTest
@testable import DBAsynchronousiOS

final class APISessionTests: XCTestCase {
    var sut: ApiSessionContract?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        sut = APISession(urlSession: urlSession)
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoginURLRequest() async throws {
        // Given
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "jwt", withExtension: "txt"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let loginURLRequest = LoginURLRequest(
            user: "regularuser@keepcoding.es",
            password: "Regularuser1"
        )
        let jwtData = try await sut?.request(loginURLRequest)
        
        // Then
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/auth/login")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(
            forHTTPHeaderField: "Authorization"), "Basic cmVndWxhcnVzZXJAa2VlcGNvZGluZy5lczpSZWd1bGFydXNlcjE="
        )
        XCTAssertNotNil(jwtData)
    }
    
    func testLoginURLRequest_ShouldReturnError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let request = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 401))
            return (request, Data())
        }
        
        // When
        let loginURLRequest = LoginURLRequest(
            user: "user@keepcoding.es",
            password: "Regular"
        )
        var apiError: APIError?
        do {
            let _ = try await sut?.request(loginURLRequest)
            XCTFail("Login error expected")
        } catch let error as APIError {
            apiError = error
        }
        
        // Then
        let unauthorizedAPIError = try XCTUnwrap(apiError)
        XCTAssertEqual(unauthorizedAPIError.url, "/api/auth/login")
        XCTAssertEqual(unauthorizedAPIError.reason, "Wrong email or password. Please log in again.")
        XCTAssertEqual(unauthorizedAPIError.statusCode, 401)
    }
    
    func testGetHerosURLRequest() async throws {
        // Given
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource:"Heros", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let heroDTOList = try await sut?.request(GetHerosURLRequest())
        
        // Then
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(heroDTOList)
        XCTAssertEqual(heroDTOList?.count, 15)
        XCTAssertEqual(heroDTOList?.first?.name, "Maestro Roshi")
    }
    
    func testGetHerosURLRequest_ShouldReturnError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        var apiError: APIError?
        do {
            let _ = try await sut?.request(GetHerosURLRequest())
            XCTFail("GetHeros error expected")
        } catch let error as APIError {
            apiError = error
        }
        
        // Then
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.statusCode, 500)
        XCTAssertEqual(apiError?.reason, "There was a server error")
    }
    
    func testGetHeroURLRequest() async throws {
        // Given
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "Hero", withExtension: "json"))
            let data = try (Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let getHerosURLRequest = GetHerosURLRequest(name: "Goku")
        let heroDTOList = try await sut?.request(getHerosURLRequest)
        
        // Then
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        let heroDTO = try XCTUnwrap(heroDTOList?.first)
        XCTAssertEqual(heroDTO.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        XCTAssertEqual(heroDTO.name, "Goku")
        XCTAssertEqual(heroDTO.info, "Sobran las presentaciones cuando se habla de Goku. El Saiyan fue enviado al planeta Tierra, pero hay dos versiones sobre el origen del personaje. Según una publicación especial, cuando Goku nació midieron su poder y apenas llegaba a dos unidades, siendo el Saiyan más débil. Aun así se pensaba que le bastaría para conquistar el planeta. Sin embargo, la versión más popular es que Freezer era una amenaza para su planeta natal y antes de que fuera destruido, se envió a Goku en una incubadora para salvarle.")
        XCTAssertEqual(heroDTO.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")
        XCTAssertEqual(heroDTO.favorite, true)
    }
    
    func testGetHeroURLRequest_ShouldReturnError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        var apiError: APIError?
        do {
            let getHerosURLRequest = GetHerosURLRequest(name: "Gohan:(")
            let _ = try await sut?.request(getHerosURLRequest)
            XCTFail("GetHero error expected")
        } catch let error as APIError {
            apiError = error
        }
        
        // Then
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.statusCode, 500)
        XCTAssertEqual(apiError?.reason, "There was a server error")
    }
    
    func testGetTransformationsURLRequest() async throws {
        // Given
        var receivedRequest : URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: APISessionTests.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let transformationsURLRequest = GetTransformationsURLRequest(heroIdentifier: "5809A7BC-DE77-4DA4-939B-D5F4EB00FAA")
        let transformationDTOList = try await sut?.request(transformationsURLRequest)
        
        // Then
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/tranformations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(transformationDTOList)
        XCTAssertEqual(transformationDTOList?.count, 14)
        XCTAssertEqual(transformationDTOList?.first?.name, "1. Oozaru – Gran Mono")
    }
    
    func testGetTransformationsURLRequest_ShouldReturnError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 500))
            return (httpURLResponse, Data())
        }
        
        // When
        var apiError: APIError?
        do {
            let transformationsURLRequest = GetTransformationsURLRequest(heroIdentifier: "5809A7BC-DE77-4DA4-939B-D5F4EB00FAA")
            let _ = try await sut?.request(transformationsURLRequest)
            XCTFail("GetTransformations error expected")
        } catch let error as APIError {
            apiError = error
        }
        
        // Then
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.statusCode, 500)
        XCTAssertEqual(apiError?.reason, "There was a server error")
    }
}
