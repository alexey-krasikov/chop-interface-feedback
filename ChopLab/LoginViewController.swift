//
//  LoginViewController.swift
//  ChopLab
//
//  Created by Алексей Красиков on 08.05.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var usernameDescription: UILabel!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var descriptionTextField: UILabel!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    private var userNameState: UsernameCorrectnessState = .def
    private var passwordState: PasswordCorrectnessState = .def
    
    enum UsernameCorrectnessState {
        case def
        case correct
        case empty
        case doesntFound
        case unacceptableSymbols
    }
    
    enum PasswordCorrectnessState {
        case def
        case correct
        case empty
        case unacceptableSymbols
        case dontMatch
    }
    
    public enum CorrectnessColors {
        static let good = UIColor.label
        static let bad = UIColor.systemRed
    }
    
    private func colorForUsernameState(state: UsernameCorrectnessState, isTextField: Bool) -> UIColor {
        if isTextField && (state == .correct || state == .def) {
            return .clear
        }
        
        switch state {
        case .correct, .def:
            return CorrectnessColors.good
        default:
            return CorrectnessColors.bad
        }
    }
    
    private func colorForPasswordState(state: PasswordCorrectnessState, isTextField: Bool) -> UIColor {
        if isTextField && (state == .correct || state == .def) {
            return .clear
        }
        
        switch state {
        case .correct, .def:
            return CorrectnessColors.good
        default:
            return CorrectnessColors.bad
        }
    }
        
    private func titleForUsernameDescriptionWithState(with state: UsernameCorrectnessState) -> String {
        switch state {
        case .correct, .def:
            return "Введите имя пользователя, указанное при регистрации"
        case .empty:
            return "Необходимо заполнить имя пользователя!"
        case .doesntFound:
            return "К сожалению, выбранное имя пользователя не найдено"
        case .unacceptableSymbols:
            return "Имя пользователя не может содержать кириллицу или специальные символы"
        }
    }
    
    private func titleForPasswordDescriptionWithState(with state: PasswordCorrectnessState) -> String {
        switch state {
        case .correct, .def:
            return "Пароль должен содержать не менее восьми знаков, включать буквы, цифры и специальные символы"
        case .empty:
            return "Необходимо заполнить пароль"
        case .unacceptableSymbols:
            return "Пароль не может содержать кириллицу или специальные символы"
        case .dontMatch:
            return "Неверный пароль!"
        }
    }
    
    private func updateView() {
        usernameTextField.backgroundColor = colorForUsernameState(state: self.userNameState, isTextField: true)
        usernameDescription.textColor = colorForUsernameState(state: self.userNameState, isTextField: false)
        usernameDescription.text = titleForUsernameDescriptionWithState(with: self.userNameState)
        
        passwordTextField.backgroundColor = colorForPasswordState(state: self.passwordState, isTextField: true)
        descriptionTextField.textColor = colorForPasswordState(state: self.passwordState, isTextField: false)
        descriptionTextField.text = titleForPasswordDescriptionWithState(with: self.passwordState)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        self.loadingIndicator.isHidden = true
    }
    
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        var state: UsernameCorrectnessState
        let text = usernameTextField.text
        
        guard let text = text else { return }
        
        if (text == "") {
            state = .empty
        } else if (text.hasSpecialCharacters()) {
            state = .unacceptableSymbols
        } else if (text != "admin") {
            state = .doesntFound
        } else {
            state = .correct
        }
        
        self.userNameState = state
        
        updateView()
    }
    
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        var state: PasswordCorrectnessState
        let text = passwordTextField.text
        guard let text = text else { return }
        
        if (text == "") {
            state = .empty
        } else if (text.hasSpecialCharacters()) {
            state = .unacceptableSymbols
        } else if (text != "admin") {
            state = .dontMatch
        }
        else {
            state = .correct
        }
        
        self.passwordState = state
        
        updateView()
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        guard (self.userNameState == .correct && self.passwordState == .correct) else {
            return
        }
        
        switchLoading()
        
        
        let alert = UIAlertController(title: "Что-то пошло не так", message: "К сожалению, сервер не отвечает. Попробуйте позже!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Хорошо", comment: "Default action"), style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.switchLoading()
        }))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func switchLoading() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 0, options: .curveLinear) {
            if self.loginButton.isHidden && !self.loadingIndicator.isHidden {
                self.loginButton.isHidden = false
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
            } else {
                self.loginButton.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
            }
        }
    }
    
}
