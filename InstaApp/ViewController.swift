//
//  ViewController.swift
//  InstaApp
//
//  Created by Sude on 13.06.2025.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginTouched(_ sender: Any) {
        if mailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: mailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if error != nil {
                    self.errorMessage(titleInput: "Error", messageInput: error!.localizedDescription)
                }else{
                    self.performSegue(withIdentifier: "toFeedVc", sender: self)
                }
            }
            
        }else{
            errorMessage(titleInput: "Error", messageInput: "Enter email and password")
        }
    }
    
    @IBAction func signUpTouched(_ sender: Any) {
        
        if mailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().createUser(withEmail: mailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if error != nil {
                    self.errorMessage(titleInput: "Error", messageInput: error!.localizedDescription)
                }else{
                    self.performSegue(withIdentifier: "toFeedVc", sender: self)
                }
            }
            
        }else{
            errorMessage(titleInput: "Error", messageInput: "Enter email and password")
        }
        
    }
    
    func errorMessage(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

