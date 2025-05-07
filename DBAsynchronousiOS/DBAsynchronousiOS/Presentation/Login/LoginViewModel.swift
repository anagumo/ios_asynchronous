import Foundation
import Combine

enum LoginState {
    case loading
    case logged
    case inlineError(RegexLintError) // For errors on ui ej. below text fields
    case fullScreenError(String) // For blocking errors
    case none
}

final class LoginViewModel: ObservableObject {
    @Published var loginState: LoginState
    
    init() {
        loginState = .none
    }
    
    func login() {
        loginState = .loading
    }
}
