import UIKit
import Combine

class SplashController: UIViewController {
    // MARK: UI Components
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Subscription
    private var splashViewModel: SplashViewModel
    private var subscribers: Set<AnyCancellable>
    
    init(splashViewModel: SplashViewModel) {
        self.splashViewModel = splashViewModel
        self.subscribers = Set()
        super.init(nibName: "SplashView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Data Binding
    private func load() {
        splashViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicatorView.startAnimating()
                } else {
                    self?.activityIndicatorView.stopAnimating()
                }
            })
            .store(in: &subscribers)
    }
}
