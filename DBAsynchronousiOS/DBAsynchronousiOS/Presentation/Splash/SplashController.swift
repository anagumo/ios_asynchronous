import UIKit
import Combine

class SplashController: UIViewController {
    // MARK: UI Components
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Observed Objects
    private var splashViewModel: SplashViewProtocol
    private var subscribers: Set<AnyCancellable>
    
    // MARK: Lifecycle
    init(splashViewModel: SplashViewProtocol) {
        self.splashViewModel = splashViewModel
        self.subscribers = Set()
        super.init(nibName: "SplashView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        splashViewModel.load()
    }
    
    // MARK: Data Binding
    private func bind() {
        splashViewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    self?.renderLoading()
                case .home:
                    self?.renderHome()
                case .login:
                    self?.renderLogin()
                }
            })
            .store(in: &subscribers)
    }
    
    // MARK: State Rendering
    private func renderLoading() {
        activityIndicatorView.startAnimating()
    }
    
    private func renderHome() {
        activityIndicatorView.stopAnimating()
        debugPrint("Home")
    }
    
    private func renderLogin() {
        activityIndicatorView.stopAnimating()
        present(LoginBuilder().build(), animated: true)
    }
}
