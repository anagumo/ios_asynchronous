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
    private let loginUseCase: LoginUseCaseProtocol
    @Published var loginState: LoginState
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        loginState = .none
    }
    
    func login(user: String?, password: String?) {
        loginState = .loading
        
        Task { @MainActor in
            do {
                try await loginUseCase.run(user: user, password: password)
                loginState = .logged
            } catch let regexLintError as RegexLintError {
                loginState = .inlineError(regexLintError)
            } catch let apiError as APIError {
                loginState = .fullScreenError(apiError.reason)
            }
        }
    }
}
