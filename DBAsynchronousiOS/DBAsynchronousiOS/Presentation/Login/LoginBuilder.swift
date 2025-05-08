import UIKit

final class LoginBuilder {
    
    func build() -> UIViewController {
        let repository = AuthRepositoryImpl()
        let useCase = LoginUseCase(authRepository: repository)
        let viewModel = LoginViewModel(loginUseCase: useCase)
        let controller = LoginController(loginViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
