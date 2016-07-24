//
//  LoginViewController.swift
//  PokemonChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Validator

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        usernameField.addLeftIconToTableView(UIImage(named: "usericon"))
        passwordField.addLeftIconToTableView(UIImage(named: "passwordicon"))
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        // Attach Form Validation
        
        // Username Field - required, 3-16 chars, no special characters
        var usernameRules = ValidationRuleSet<String>()
        usernameRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Username is required")))
        usernameRules.addRule(ValidationRuleLength(min: 3, max: 16, failureError: ValidationError(message: "Username length should be between 3-16 chars")))
        usernameRules.addRule(ValidationRulePattern(pattern: "[a-z0-9_-]*", failureError: ValidationError(message: "Username can contain letters, numbers and _ and - only")))
        
        usernameField.validationRules = usernameRules
        usernameField.validateOnEditingEnd(true)
        usernameField.validationHandler = validationHandler
        
        // Password Field - required, min 8 chars
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Password is required")))
        passwordRules.addRule(ValidationRuleLength(min: 3, max: 100, failureError: ValidationError(message: "Password should have min. 8 chars")))
        
        passwordField.validationRules = passwordRules
        passwordField.validateOnEditingEnd(true)
        passwordField.validationHandler = validationHandler
    }
    
    // MARK: Form Handling
    func validationHandler(result: ValidationResult, control: UITextField) {
        switch result {
        case .Valid:
            errorLabel.text = nil
            hideError()
        case .Invalid(let failures):
            errorLabel.text = failures.first?.message
        }
    }
    func validateForm() -> Bool {
        if usernameField.validate() == .Valid {
            if passwordField.validate() == .Valid {
                return true
            }
        }
        return false
    }
    
    // MARK: Signup Handling
    @IBAction func initiateLogin() {
        if validateForm() == true {
            
        } else {
            showErrorForTime(5)
        }
    }
    
    //MARK: Error Label Handling
    func showErrorForTime(time: NSTimeInterval) {
        UIView.animateWithDuration(0.5) {
            self.errorLabelHeight.constant = 44
            self.view.layoutIfNeeded()
        }
        Utils.delay(time, closure: {
            self.hideError()
        })
    }
    
    func hideError() {
        UIView.animateWithDuration(0.5) {
            self.errorLabelHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = Colors.selectedTextFieldColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.whiteColor()
    }
}
