import UIKit
import Combine
import CombineCocoa

class LoginController: UIViewController {
    // MARK: UI Components
    @IBOutlet var userTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var userErrorLabel: UILabel!
    @IBOutlet var passwordErrorLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    // MARK: Observed Objects
    private let loginViewModel: LoginViewModel
    private var subscribers: Set<AnyCancellable>
    
    // MARK: Lifecycle
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        subscribers = Set()
        super.init(nibName: "LoginView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: Binding
    private func bind() {
        userTextField.textPublisher.compactMap { $0 }
            .combineLatest(passwordTextField.textPublisher.compactMap { $0 })
            .map { user, password in
                return !user.isEmpty && !password.isEmpty
            }.receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &subscribers)
        
        loginButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loginViewModel.login()
            }.store(in: &subscribers)
        
        loginViewModel.$loginState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginState in
                switch loginState {
                case .loading:
                    self?.renderLoading()
                case .logged:
                    self?.renderLogged()
                case let .inlineError(regexLintError):
                    self?.renderInlineError(regexLintError)
                case let .fullScreenError(errorMessage):
                    self?.renderFullScreenError(errorMessage)
                case .none:
                    break
                }
            }.store(in: &subscribers)
    }
    
    // MARK: Rendering State
    
    private func renderLoading() {
        userErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        loginButton.configuration?.showsActivityIndicator = true
    }
    
    private func renderLogged() {
        loginButton.configuration?.showsActivityIndicator = false
        userTextField.text = ""
        passwordTextField.text = ""
        //present(HerosBuilder().build(), animated: true)
    }
    
    private func renderInlineError(_ regexLintError: RegexLintError) {
        loginButton.configuration?.showsActivityIndicator = false
        if regexLintError == .email {
            userErrorLabel.text = regexLintError.errorDescription
            userErrorLabel.isHidden = false
        } else if regexLintError == .password {
            passwordErrorLabel.text = regexLintError.errorDescription
            passwordErrorLabel.isHidden = false
        }
    }
    
    private func renderFullScreenError(_ errorMessage: String) {
        loginButton.configuration?.showsActivityIndicator = false
        /*present(
            AlertBuilder().build(title: "Error", message: errorMessage),
            animated: true
        )*/
    }
}
