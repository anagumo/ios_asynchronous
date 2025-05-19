import UIKit
import Combine
import CombineCocoa

class LoginController: UIViewController {
    // MARK: UI Components
    @IBOutlet private var userTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var userErrorLabel: UILabel!
    @IBOutlet private var passwordErrorLabel: UILabel!
    @IBOutlet private var loginButton: UIButton!
    
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
        bindUIComponents()
        bindLoginViewModel()
    }
    
    private func bindUIComponents() {
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
                self?.loginViewModel.login(
                    user: self?.userTextField.text,
                    password: self?.passwordTextField.text
                )
            }.store(in: &subscribers)
    }
    
    private func bindLoginViewModel() {
        loginViewModel.appState.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.renderLoading(isLoading)
            }.store(in: &subscribers)
        
        loginViewModel.appState.$logged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] logged in
                self?.render(logged)
            }.store(in: &subscribers)
        
        loginViewModel.appState.$regexError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] regexError in
                self?.render(regexError)
            }.store(in: &subscribers)
        
        loginViewModel.appState.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.render(errorMessage)
            }.store(in: &subscribers)
    }
    
    // MARK: Rendering State
    private func renderLoading(_ isLoading: Bool) {
        userErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        loginButton.configuration?.showsActivityIndicator = isLoading
    }
    
    private func render(_ logged: Bool) {
        guard logged else { return }
        loginButton.configuration?.showsActivityIndicator = false
        userTextField.text = ""
        passwordTextField.text = ""
        show(HerosBuilder().build(), sender: self)
    }
    
    private func render(_ regexError: RegexLintError) {
        loginButton.configuration?.showsActivityIndicator = false
        if regexError == .email {
            userErrorLabel.text = regexError.errorDescription
            userErrorLabel.isHidden = false
        } else if regexError == .password {
            passwordErrorLabel.text = regexError.errorDescription
            passwordErrorLabel.isHidden = false
        }
    }
    
    private func render(_ errorMessage: String?) {
        guard let errorMessage else { return }
        loginButton.configuration?.showsActivityIndicator = false
        present(
            AlertBuilder().build(title: "Error", message: errorMessage),
            animated: true
        )
    }
}
