import Foundation
import Combine

final class HeroViewModel: ObservableObject {
    private var name: String
    private let getHeroUseCase: GetHeroUseCaseProtocol
    private let getTransformationsUseCase: GetTransformationsUseCaseProtocol
    // MARK: Published objects
    let appState: AppState
    @Published var hero: Hero?
    @Published var transformations: [Transformation]
    
    init(name: String,
         getHeroUseCase: GetHeroUseCaseProtocol,
         getTransformationsUseCase: GetTransformationsUseCaseProtocol,
         appState: AppState) {
        self.name = name
        self.getHeroUseCase = getHeroUseCase
        self.getTransformationsUseCase = getTransformationsUseCase
        self.appState = appState
        self.transformations = []
    }
    
    func load() {
        appState.isLoading = true
        
        Task { @MainActor in
            do {
                self.hero = try await getHeroUseCase.run(name: name)
            } catch let error as PresentationError {
                appState.error = error.reason
            } catch let error as APIError {
                appState.error = error.reason
            }
            appState.isLoading = false
        }
    }
    
    func loadTransformations() {
        guard let heroIdentifier = hero?.identifier else { return }
        
        Task { @MainActor in
            do {
                self.transformations = try await getTransformationsUseCase.run(heroIdentifier: heroIdentifier)
            } catch let error as PresentationError {
                debugPrint(error.reason)
            } catch let error as APIError {
                debugPrint(error.reason)
            }
        }
    }
}
