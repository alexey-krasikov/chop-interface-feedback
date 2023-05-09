//
//  RegistrationViewController.swift
//  ChopLab
//
//  Created by Алексей Красиков on 08.05.2023.
//

import UIKit

final class RegistrationViewController: UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userNameDescription: UILabel!
    
    @IBOutlet var passwordsTextField: UITextField!
    @IBOutlet var secondaryPasswortTextfield: UITextField!
    @IBOutlet var passwordDescription: UILabel!
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    private var userNameState: UsernameCorrectnessState = .def
    private var passwordState: PasswordCorrectnessState = .def
    
    enum UsernameCorrectnessState {
        case def
        case correct
        case empty
        case alreadyExists
        case unacceptableSymbols
    }
    
    enum PasswordCorrectnessState {
        case def
        case correct
        case empty
        case emptySecondary
        case tooWeek
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
            return "Можно использовать буквы латинского алфавита и цифры."
        case .empty:
            return "Необходимо заполнить имя пользователя!"
        case .alreadyExists:
            return "К сожалению, выбранное имя пользователя занято."
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
        case .emptySecondary:
            return "Введите пароль еще раз"
        case .tooWeek:
            return "Пароль слишком простой. Пароль должен содержать специальные символы и быть не менее 8 символов"
        case .dontMatch:
            return "Пароли не совпадают"
        }
    }
    
    private func updateView() {
        userNameTextField.backgroundColor = colorForUsernameState(state: self.userNameState, isTextField: true)
        userNameDescription.textColor = colorForUsernameState(state: self.userNameState, isTextField: false)
        userNameDescription.text = titleForUsernameDescriptionWithState(with: self.userNameState)
        
        passwordsTextField.backgroundColor = colorForPasswordState(state: self.passwordState, isTextField: true)
        secondaryPasswortTextfield.backgroundColor = colorForPasswordState(state: self.passwordState, isTextField: true)
        passwordDescription.textColor = colorForPasswordState(state: self.passwordState, isTextField: false)
        passwordDescription.text = titleForPasswordDescriptionWithState(with: self.passwordState)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        self.loadingIndicator.isHidden = true

    }
    
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        var state: UsernameCorrectnessState
        let text = userNameTextField.text
        
        guard let text = text else { return }
        
        if (text == "") {
            state = .empty
        } else if (text == "admin") {
            state = .alreadyExists
        } else if (text.hasSpecialCharacters()) {
            state = .unacceptableSymbols
        } else {
            state = .correct
        }
        
        self.userNameState = state
        
        updateView()
    }
    
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        var state: PasswordCorrectnessState
        let text = passwordsTextField.text
        guard let text = text else { return }
        
        if (text == "") {
            state = .empty
        } else if (text.count < 8) {
            state = .tooWeek
        } else {
            state = .correct
        }
        
        self.passwordState = state
        
        updateView()
    }
    
    
    @IBAction func passwordSecondaryTextFieldChanged(_ sender: Any) {
        var state: PasswordCorrectnessState
        let text = passwordsTextField.text
        let textSecondary = secondaryPasswortTextfield.text
        guard let text = text, let textSecondary = textSecondary else { return }
        
        if (textSecondary == "") {
            state = .emptySecondary
        } else if (text != textSecondary) {
            state = .dontMatch
        } else {
            state = .correct
        }
        
        self.passwordState = state
        
        updateView()
    }
    
    @IBAction func registerTapped(_ sender: Any) {
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
            if self.registerButton.isHidden && !self.loadingIndicator.isHidden {
                self.registerButton.isHidden = false
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                
                self.userNameTextField.isEnabled = true
                self.passwordsTextField.isEnabled = true
                self.secondaryPasswortTextfield.isEnabled = true
            } else {
                self.registerButton.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                
                self.userNameTextField.isEnabled = false
                self.passwordsTextField.isEnabled = false
                self.secondaryPasswortTextfield.isEnabled = false
            }
        }
    }
    
}

extension String {
    func hasSpecialCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
            
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
        
        return false
    }
}
