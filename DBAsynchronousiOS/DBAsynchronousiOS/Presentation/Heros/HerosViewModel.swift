import Foundation
import Combine

final class HerosViewModel: ObservableObject {
    private var getHerosUseCase: GetHerosUseCaseProtocol
    // MARK: Published objects
    let appState: AppState
    @Published var heros: [Hero]
    
    init(getHerosUseCase: GetHerosUseCaseProtocol,
         appState: AppState) {
        self.getHerosUseCase = getHerosUseCase
        self.appState = appState
        heros = []
    }
    
    func load() {
        appState.isLoading = true
        
        Task { @MainActor in
            do {
                self.heros = try await getHerosUseCase.run()
            } catch let error as PresentationError {
                appState.error = error.reason
            } catch let error as APIError {
                appState.error = error.reason
            }
            appState.isLoading = false
        }
    }
    
    func get(by position: Int) -> String? {
        guard position < heros.count else {
            return nil
        }
        return heros[position].name
    }
}
