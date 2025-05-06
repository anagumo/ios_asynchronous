import UIKit

final class SplashBuilder {
    
    func build() -> UIViewController {
        let splashViewModel = SplashViewModel()
        return SplashController(splashViewModel: splashViewModel)
    }
}
