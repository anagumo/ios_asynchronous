import Foundation
@testable import DBAsynchronousiOS

final class MockAuthDataSource: AuthDataSourceProtocol {
    
    func get() async throws -> String {
        guard let jwt = UserDefaults.standard.string(forKey: "jwtDebug") else {
            throw PresentationError.session("Session not found or expired, log in again")
        }
        return jwt
    }
    
    func set(_ jwt: Data) async throws {
        let jwtString = String(decoding: jwt, as: UTF8.self)
        UserDefaults.standard.setValue(jwtString, forKey: "jwtDebug")
    }
    
    func clear() async throws {
        UserDefaults.standard.removeObject(forKey: "jwtDebug")
    }
}
