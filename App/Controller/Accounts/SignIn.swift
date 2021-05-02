//
//  Sign-In.swift
//  App
//
//  Created by Rahul Guni on 4/26/21.
//

import UIKit
import Parse


class SignIn: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.isModalInPresentation = true
    }

    @IBAction func signIn(_ sender: UIButton) {
        PFUser.logInWithUsername(inBackground:email.text!, password:password.text!) {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
            currentUser = PFUser.current()
            self.performSegue(withIdentifier: "reloadAccount", sender: self)
          } else {
            if let error = error {
              let errorString = error.localizedDescription
              // Show the errorString somewhere and let the user try again.
                let alert = UIAlertController(title: "Error Loggin In", message: errorString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
          }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

