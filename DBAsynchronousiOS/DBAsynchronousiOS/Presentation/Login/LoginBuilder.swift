import UIKit

final class LoginBuilder {
    
    func build() -> UIViewController {
        let viewModel = LoginViewModel()
        let controller = LoginController(loginViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
