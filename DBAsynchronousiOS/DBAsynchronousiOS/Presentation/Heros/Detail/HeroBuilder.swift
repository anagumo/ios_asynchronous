import UIKit

final class HeroBuilder {
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func build() -> UIViewController {
        let viewModel = HeroViewModel(
            name: name,
            getHeroUseCase: GetHeroUseCase(),
            getTransformationsUseCase: GetTransformationsUseCase(),
            appState: .shared
        )
        let controller = HeroController(heroViewModel: viewModel)
        return controller
    }
}
