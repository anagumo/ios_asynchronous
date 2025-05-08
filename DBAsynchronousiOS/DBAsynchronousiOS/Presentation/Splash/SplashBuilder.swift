import UIKit

final class SplashBuilder {
    
    func build() -> UIViewController {
        let viewModel = SplashViewModel(
            getSessionUseCase: GetSessionUseCase()
        )
        return SplashController(splashViewModel: viewModel)
    }
}
