import Foundation
import KeychainSwift

protocol AuthDataSourceProtocol {
    func get() -> Data?
    func set(_ jwt: Data)
    func clear()
}

final class AuthDataSource: AuthDataSourceProtocol {
    static let shared = AuthDataSource()
    private let keychain = KeychainSwift()
    
    func get() -> Data? {
        keychain.getData("jwtData")
    }
    
    func set(_ jwt: Data) {
        keychain.set(jwt, forKey: "jwtData")
    }
    
    func clear() {
        keychain.clear()
    }
}
