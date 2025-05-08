import Foundation

struct GetHerosURLRequest: URLRequestComponents {
    typealias Response = [HeroDTO]
    var path: String = "/api/heros/all"
    var httpMethod: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    
    init(name: String = "") {
        body = EncodedBody(name: name)
    }
}

extension GetHerosURLRequest {
    struct EncodedBody: Encodable {
        let name: String
    }
}
