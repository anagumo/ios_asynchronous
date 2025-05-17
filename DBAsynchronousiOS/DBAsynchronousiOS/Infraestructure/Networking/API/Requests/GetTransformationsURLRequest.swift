import Foundation

struct GetTransformationsURLRequest: URLRequestComponents {
    typealias Response = [TransformationDTO]
    var path: String = "/api/heros/tranformations"
    var httpMethod: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    
    init(heroIdentifier: String) {
        body = EncodedBody(id: heroIdentifier)
    }
}

extension GetTransformationsURLRequest {
    struct EncodedBody: Encodable {
        let id: String
    }
}
