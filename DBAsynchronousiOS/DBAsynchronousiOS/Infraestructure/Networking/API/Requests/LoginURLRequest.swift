import Foundation

struct LoginURLRequest: URLRequestComponents {
    typealias Response = Data
    var path: String = "/api/auth/login"
    var httpMethod: HTTPMethod = .POST
    var authorized: Bool = false
    var headers: [String : String]
    
    init(user: String, password: String) {
        let loginCredentials = String(format: "%@:%@", user, password)
        let loginData = Data(loginCredentials.utf8)
        let base64LoginData = loginData.base64EncodedString()
        headers = [
            "Authorization": "Basic \(base64LoginData)"
        ]
    }
}
