//
//  LoginViewController.swift
//  PokemonChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        usernameField.delegate = self
        passwordField.delegate = self
        
        let usernameIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        usernameIcon.contentMode = .Center
        usernameIcon.image = UIImage(named: "usericon")
        usernameField.leftView = usernameIcon
        usernameField.leftViewMode = .Always
        
        let passwordIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 60, height: 20))
        passwordIcon.contentMode = .Center
        passwordIcon.image = UIImage(named: "passwordicon")
        passwordField.leftView = passwordIcon
        passwordField.leftViewMode = .Always
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
