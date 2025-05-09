import UIKit

final class HerosBuilder {
    
    func build() -> UIViewController {
        let useCase = GetHerosUseCase()
        let viewModel = HerosViewModel(getHerosUseCase: useCase)
        let controller = HerosController(herosViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
