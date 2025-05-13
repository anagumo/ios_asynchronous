import UIKit

final class HeroBuilder {
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func build() -> UIViewController {
        let useCase = GetHeroUseCase()
        let viewModel = HeroViewModel(
            name: name,
            getHeroUseCase: useCase,
            appState: .shared
        )
        let controller = HeroController(heroViewModel: viewModel)
        return controller
    }
}
