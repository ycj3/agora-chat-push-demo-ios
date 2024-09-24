//
//  LoginViewController.swift

//
//  Created by Carlson Yuan on 2023/8/3.
//


import UIKit
import AgoraChat

public final class LoginViewController: UIViewController {
    
    public typealias DidConnectUserHandler = (String) -> Void

    private let didConnectUser: DidConnectUserHandler

    private lazy var userIdLabel: UILabel = {
        let userIdLabel: UILabel = UILabel()
        userIdLabel.text = "USER ID"
        userIdLabel.font = .boldSystemFont(ofSize: 13)
        userIdLabel.textColor = .secondaryLabel
        return userIdLabel
    }()

    private lazy var userIdTextField: UITextField = {
        let userIdTextField = UITextField()
        userIdTextField.placeholder = "USER ID"
        userIdTextField.text = "demo_user_1"
        userIdTextField.font = .systemFont(ofSize: 24)
        userIdTextField.textColor = .black
        userIdTextField.tintColor = .systemBlue
        userIdTextField.borderStyle = .roundedRect
        userIdTextField.backgroundColor = .white
        return userIdTextField
    }()
    
    private lazy var userTokenLabel: UILabel = {
        let userIdLabel: UILabel = UILabel()
        userIdLabel.text = "USER TOKEN"
        userIdLabel.font = .boldSystemFont(ofSize: 13)
        userIdLabel.textColor = .secondaryLabel
        return userIdLabel
    }()
    private lazy var userTokenTextField: UITextField = {
        let userIdTextField = UITextField()
        userIdTextField.placeholder = "USER TOKEN"
        userIdTextField.text = "007eJxSYLiy72BV4IUMi4s7C2LO1b66cTLvecjP6/lXGaXOfYpf9e6+AkNKsnFKsnlqooFZioWJhWmyZbKRWap5UmKKgYmFeZKxyYvQT2kNgYwMlWx8TIwMrAyMDIwMID43Q0pqbn58aXFqUbwhIAAA//+Wpya+"
        userIdTextField.font = .systemFont(ofSize: 24)
        userIdTextField.textColor = .black
        userIdTextField.tintColor = .systemBlue
        userIdTextField.borderStyle = .roundedRect
        userIdTextField.backgroundColor = .white
        return userIdTextField
    }()

    private lazy var connectButton: UIButton = {
        let connectButton: UIButton = UIButton()
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(didTouchConnectButton), for: .touchUpInside)
        connectButton.backgroundColor = .systemBlue
        connectButton.layer.cornerRadius = 22
        connectButton.clipsToBounds = true
        return connectButton
    }()

    public init(didConnectUser: @escaping DidConnectUserHandler) {
        self.didConnectUser = didConnectUser
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        loadCachedUser()
    }

    private func setupSubviews() {
        view.addSubview(userIdLabel)
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            userIdLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIdLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        view.addSubview(userIdTextField)
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIdTextField.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 5),
            userIdTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIdTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        view.addSubview(userTokenLabel)
        userTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTokenLabel.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: 30),
            userTokenLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userTokenLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(userTokenTextField)
        userTokenTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTokenTextField.topAnchor.constraint(equalTo: userTokenLabel.bottomAnchor, constant: 5),
            userTokenTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userTokenTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.topAnchor.constraint(equalTo: userTokenTextField.bottomAnchor, constant: 30),
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            connectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func loadCachedUser() {
        if let userId = UserConnectionUseCase.shared.userId {
            userIdTextField.text = userId
        }

        if UserConnectionUseCase.shared.isAutoLogin {
            connectUser()
        }
    }

    private func connectUser() {
        view.endEditing(true)

        guard
            let userId = userIdTextField.text,
            validateText(str: userId)
        else {
            presentAlert(title: "AgoraChatError", message: "User ID are required.")
            return
        }
        
        guard
            let userToken = userTokenTextField.text,
            validateText(str: userToken)
        else {
            presentAlert(title: "AgoraChatError", message: "User Token are required.")
            return
        }

        updateUIForConnecting()
        UserConnectionUseCase.shared.login(userId: userId, agoraToken: userToken) { [weak self] result in
            self?.updateUIForDefault()
            
            switch result {
            case .success(let username):
                self?.didConnectUser(username)
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }

    private func validateText(str: String) -> Bool {
        str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func updateUIForDefault() {
        userIdTextField.isEnabled = true
        userTokenTextField.isEnabled = true
        connectButton.isEnabled = true
        connectButton.setTitle("Connect", for: .normal)
    }

    private func updateUIForConnecting() {
        userIdTextField.isEnabled = false
        connectButton.isEnabled = false
        userTokenTextField.isEnabled = false
        connectButton.setTitle("Connecting...", for: .normal)
    }
    
    private func updateUIForConnected() {
        userIdTextField.isEnabled = false
        userTokenTextField.isEnabled = false
        connectButton.isEnabled = false
        connectButton.setTitle("Connected", for: .normal)
    }

    @objc private func didTouchConnectButton(_ sender: UIButton) {
        connectUser()
    }
    
}


// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userIdTextField {
            connectUser()
            textField.resignFirstResponder()
        }

        return true
    }
    
}
