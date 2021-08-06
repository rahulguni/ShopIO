//
//  Sign-In.swift
//  App
//
//  Created by Rahul Guni on 4/26/21.
//

import UIKit
import Parse


class SignInViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    /* Since Sign In gets called from different places, declare a variable to perform
      segue accordingly. */
    var dismiss : forSignIn?
    
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
                //Save last login data
                user!["lastLogin"] = NSDate()
                user?.saveInBackground{(success, error) in
                    if(success) {
                        if(self.dismiss == forSignIn.forAccount) {
                            self.performSegue(withIdentifier: "reloadAccount", sender: self)
                        }
                        else if(self.dismiss == forSignIn.forMyShop){
                            self.performSegue(withIdentifier: "reloadMyShop", sender: self)
                        }
                        else if(self.dismiss == forSignIn.forMyCart) {
                            self.performSegue(withIdentifier: "reloadMyCart", sender: self)
                        }
                        else if(self.dismiss == forSignIn.forMyProduct) {
                            self.performSegue(withIdentifier: "reloadMyProduct", sender: self)
                        }
                        else{
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else {
                        let alert = networkErrorAlert(title: "Error Signing In.", errorString: error!.localizedDescription)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                if let error = error {
                    let errorString = error.localizedDescription
                    // Show the errorString somewhere and let the user try again.
                    let alert = networkErrorAlert(title: "Error Signing In.", errorString: errorString)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

