//
//  RegisterViewController.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 21/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    //MARK:- Interface Builder
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK:- ViewController's LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- General Methods
    func showAlert(titleString title:String = "", messageString message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        })
        alertController.addAction(action)
        self.present(alertController, animated:true, completion:nil)
    }
    
    func createUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showAlert(titleString: "Error", messageString: "Email address is already in use. Please try to login or reset your password!")
                } else {
                    self.showAlert(titleString: "Error", messageString: error.localizedDescription)
                }
                
            } else {
                var userDataDic = [String: Any]()
                userDataDic["id"] = Auth.auth().currentUser!.uid
                userDataDic["email"] = Auth.auth().currentUser!.email!
                User.currentUser.saveUserInformation(userInfo: userDataDic)
                StoryboardManager.segueToMain()
            }
        }
    }
    
    func isValidateInputs() -> Bool {
        if self.emailTextField.text == "" {
            self.showAlert(messageString: "Please enter email address!")
            return false
        } else if self.passwordTextField.text == "" {
            self.showAlert(messageString: "Please enter password!")
            return false
        } else {
            return true
        }
    }
}

//MARK:- Button Actions
extension RegisterViewController {
    @IBAction func loginButtonPressed() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed() {
        self.view.endEditing(true)
        if self.isValidateInputs() {
            self.createUser(email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
}
