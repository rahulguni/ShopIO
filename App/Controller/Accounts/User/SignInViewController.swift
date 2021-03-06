import UIKit
import Parse

/**/
/*
class SignInViewController

DESCRIPTION
        This class is a UIViewController that controls SignIn.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        04/26/2021
 
*/
/**/

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
        self.hideKeyboardWhenTappedAround() 
    }
    
    //Action for sign in button click.
    @IBAction func signIn(_ sender: UIButton) {
        if(self.email.text!.isEmpty || self.password.text!.isEmpty) {
            let alert = customNetworkAlert(title: "Missing Fields", errorString: "Please fill out email and password to log in.")
            self.present(alert, animated: true, completion: nil)
        }
        else{
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
                            else if(self.dismiss == forSignIn.forInbox) {
                                self.performSegue(withIdentifier: "reloadInbox", sender: self)
                            }
                            else{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            let alert = customNetworkAlert(title: "Error Signing In.", errorString: error!.localizedDescription)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    if let error = error {
                        let errorString = error.localizedDescription
                        // Show the errorString somewhere and let the user try again.
                        let alert = customNetworkAlert(title: "Error Signing In.", errorString: errorString)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

