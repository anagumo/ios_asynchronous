import Foundation
import Combine

enum SplashState {
    case loading
    case home
    case login
}

// Defined just to test how to expose a Publisher, but is to verbose
protocol SplashViewProtocol {
    func load()
    var statePublisher: AnyPublisher<SplashState, Never> { get }
}

final class SplashViewModel: ObservableObject, SplashViewProtocol {
    @Published private(set) var state: SplashState
    var statePublisher: AnyPublisher<SplashState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init() {
        state = .loading
    }
    
    func load() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            state = .login
        }
    }
}
