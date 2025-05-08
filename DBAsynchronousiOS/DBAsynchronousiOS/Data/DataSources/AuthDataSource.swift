import Foundation
import KeychainSwift

protocol AuthDataSourceProtocol {
    func get() async throws -> String
    func set(_ jwt: Data) async throws
    func clear() async throws
}

final class AuthDataSource: AuthDataSourceProtocol {
    static let shared = AuthDataSource()
    private let keychain = KeychainSwift()
    
    func get() async throws -> String {
        guard let jwt = keychain.get("jwtData") else {
            throw PresentationError.session("Session not found or expired, log in again")
        }
        return jwt
    }
    
    func set(_ jwt: Data) async throws {
        guard keychain.set(jwt, forKey: "jwtData") else {
            throw PresentationError.session("Failed to save session, try again")
        }
    }
    
    func clear() async throws {
        guard keychain.clear() else {
            throw PresentationError.session("Falied to clear session, restart the app")
        }
    }
}
