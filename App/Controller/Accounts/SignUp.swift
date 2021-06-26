//
//  Sign-Up.swift
//  App
//
//  Created by Rahul Guni on 4/26/21.
//

import UIKit
import Parse

class SignUp: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordRe: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //Add user to table
    @IBAction func signUp(_ sender: Any) {
        let user = PFUser()
        if(lastName.text == "" || email.text == "" || password.text == "" || phone.text == ""){
            let alert = UIAlertController(title: "Error Signing Up", message: "One or more entry field missing. Please fill out all the details.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        if(password.text == passwordRe.text){
            //Using email as username
            user.username = email.text
            user.email = email.text
            user.password = password.text
            user["fName"] = firstName.text
            user["lName"] = lastName.text
            user["phone"] = Int(phone.text!)
            user["lastLogin"] = NSDate()
            
            user.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                  let errorString = error.localizedDescription
                  // Show the errorString somewhere and let the user try again.
                    let alert = networkErrorAlert(title: "Error Signing Up", errorString: errorString)
                    self.present(alert, animated: true, completion: nil)
                } else {
                  // Hooray! Let them use the app now.
                    currentUser = PFUser.current()
                    self.performSegue(withIdentifier: "goToAddress", sender: self)
                }
            }
            
        }
        else{
            //throw error
            password.text = "";
            passwordRe.text = "";
            let alert = networkErrorAlert(title: "Error Signing Up", errorString: "Passwords do not match. Please try again.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reloadAccount", sender: self)
    }
    
}
