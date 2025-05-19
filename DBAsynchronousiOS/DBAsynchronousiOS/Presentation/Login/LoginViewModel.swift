import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    private let loginUseCase: LoginUseCaseProtocol
    var appState: AppState
    
    init(loginUseCase: LoginUseCaseProtocol, appState: AppState) {
        self.loginUseCase = loginUseCase
        self.appState = appState
    }
    
    func login(user: String?, password: String?) {
        appState.isLoading = true
        
        Task { @MainActor in
            do {
                try await loginUseCase.run(user: user, password: password)
                appState.logged = true
            } catch let error as RegexLintError {
                appState.regexError = error
            } catch let error as APIError {
                appState.error = error.reason
            }
        }
        appState.isLoading = false
    }
}
