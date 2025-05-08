import Foundation

protocol URLRequestComponents {
    // For Url Components
    var host: String { get }
    var path: String { get }
    var queryParameters: [String:String]? { get }
    // For Url Request
    var httpMethod: HTTPMethod { get }
    var headers: [String:String] { get }
    var body: Encodable? { get }
    var authorized: Bool { get }
    // For HTTP Response
    associatedtype Response: Decodable // The expected type is defined by the type that conforms this protocol
}

// MARK: - Default values for HTTP Request Components
extension URLRequestComponents {
    var host: String { "dragonball.keepcoding.education" }
    var queryParameters: [String : String]? { [:] }
    var headers: [String : String] { [:] }
    var body: Encodable? { nil }
}
