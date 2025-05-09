import Foundation
import Combine

enum HerosState {
    case loading
    case error(String)
    case none
}

final class HerosViewModel {
    private var getHerosUseCase: GetHerosUseCaseProtocol
     // MARK: Published objects
    @Published var state: HerosState
    @Published var heroList: [Hero]
    
    init(getHerosUseCase: GetHerosUseCaseProtocol) {
        self.getHerosUseCase = getHerosUseCase
        state = .loading
        heroList = []
    }
    
    func load() {
        Task { @MainActor in
            do {
                let heros = try await getHerosUseCase.run(name: "")
                state = .none
                heroList = heros
            } catch let error as PresentationError {
                state = .error(error.reason)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
