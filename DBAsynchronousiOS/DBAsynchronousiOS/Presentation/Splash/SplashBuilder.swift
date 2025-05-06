import UIKit

final class SplashBuilder {
    
    func build() -> UIViewController {
        let viewModel = SplashViewModel(
            authDataSource: AuthDataSource.shared
        )
        return SplashController(splashViewModel: viewModel)
    }
}
