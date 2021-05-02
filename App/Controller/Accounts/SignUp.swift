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
        if(password.text == passwordRe.text){
            //Using email as username
            user.username = email.text
            user.email = email.text
            user.password = password.text
            user["fName"] = firstName.text
            user["lName"] = lastName.text
            user["phone"] = phone.text
            
            user.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                  let errorString = error.localizedDescription
                  // Show the errorString somewhere and let the user try again.
                    let alert = UIAlertController(title: "Error Signing Up", message: errorString, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                  // Hooray! Let them use the app now.
                    currentUser = PFUser.current()
                    self.performSegue(withIdentifier: "reloadAccount", sender: self)
                }
            }
            
        }
        else{
            //throw error
            print("Passwords do not match.");
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reloadAccount", sender: self)
    }
    
}
