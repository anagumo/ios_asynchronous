import UIKit

final class LoginBuilder {
    
    func build() -> UIViewController {
        let repository = AuthRepository()
        let useCase = LoginUseCase(authRepository: repository)
        let viewModel = LoginViewModel(loginUseCase: useCase)
        let controller = LoginController(loginViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
