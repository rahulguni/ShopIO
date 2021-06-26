//
//  MyShop.swift
//  App
//
//  Created by Rahul Guni on 4/30/21.
//

import UIKit
import Parse

class MyShop: UIViewController{
    
    
    @IBOutlet weak var myShopButton: UIButton!
    @IBOutlet weak var editMyShopButton: UIButton!
    
    override func viewDidLoad() {
        myShopButton.layer.cornerRadius = 45
        editMyShopButton.layer.cornerRadius = 45
        myShopButton.layer.masksToBounds = true
        editMyShopButton.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser == nil {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toSignIn") {
            let destination = segue.destination as! SignIn
            destination.dismiss = true
        }
    }
    
    @IBAction func manageShopButton(_ sender: UIButton) {
        if currentUser != nil{
            let message = "Please enter password for \(String(describing: currentUser!.username!))"
            let alert = UIAlertController(title: "Sign-In to continue", message: message, preferredStyle: .alert)
            
            alert.addTextField { (password) -> Void in
                password.placeholder = "Password"
                password.isSecureTextEntry = true
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Go", comment: "Go to ManageShopView"), style: .default, handler: { _ in
                
                let password = alert.textFields![0] // Force unwrapping because we know it exists.
                //print("Text field: \(textField.text!)")
                PFUser.logInWithUsername(inBackground:currentUser!.username!, password: password.text!) {
                    (user: PFUser?, error: Error?) -> Void in
                    if user != nil {
                        self.performSegue(withIdentifier: "goToManageShop", sender: self)
                    } else {
                        // The login failed. Check error to see why.
                        if let errormsg = error {
                            let errorString = errormsg.localizedDescription
                            // Show the errorString somewhere and let the user try again.
                            let alert = networkErrorAlert(title: "Error Signing In", errorString: errorString)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    @IBAction func myShopButton(_ sender: UIButton) {
        if currentUser != nil {
            performSegue(withIdentifier: "goTomyShopView", sender: self)
        }
        else {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
}
