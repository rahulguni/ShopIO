//
//  MyShop.swift
//  App
//
//  Created by Rahul Guni on 4/30/21.
//

import UIKit
import Parse

class MyShop: UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser == nil {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    @IBAction func manageShopButton(_ sender: UIButton) {
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
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func myShopButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goTomyShopView", sender: self)
    }
    
}
