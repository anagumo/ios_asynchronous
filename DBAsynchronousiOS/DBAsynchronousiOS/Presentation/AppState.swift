import Foundation
import Combine

final class AppState {
    static let shared = AppState()
    // MARK: Published Objects
    @Published var isLoading: Bool
    @Published var error: String?
    
    init() {
        self.isLoading = false
        self.error = nil
    }
}
