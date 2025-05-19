import Foundation
import Combine

final class AppState {
    static let shared = AppState()
    // MARK: Published Objects
    @Published var isLoading: Bool
    @Published var error: String?
    @Published var logged: Bool
    @Published var regexError: RegexLintError
    
    init() {
        self.isLoading = false
        self.error = nil
        self.logged = false
        self.regexError = .none
    }
}
