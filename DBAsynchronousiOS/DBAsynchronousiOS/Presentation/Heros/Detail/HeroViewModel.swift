import Foundation
import Combine

final class HeroViewModel: ObservableObject {
    private var name: String
    private let getHeroUseCase: GetHeroUseCase
    // MARK: Published objects
    let appState: AppState?
    @Published var hero: Hero?
    
    init(name: String,
         getHeroUseCase: GetHeroUseCase,
         appState: AppState) {
        self.name = name
        self.getHeroUseCase = getHeroUseCase
        self.appState = appState
    }
    
    func load() {
        appState?.isLoading = true
        
        Task { @MainActor in
            do {
                self.hero = try await getHeroUseCase.run(name: name)
            } catch let error as PresentationError {
                appState?.error = error.reason
            } catch let error as APIError {
                appState?.error = error.reason
            }
            appState?.isLoading = false
        }
    }
}
