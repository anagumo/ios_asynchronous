import UIKit

final class LoginBuilder {
    
    func build() -> UIViewController {
        let controller = LoginController()
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
