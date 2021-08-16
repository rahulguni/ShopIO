//
//  Sign-Up.swift
//  App
//
//  Created by Rahul Guni on 4/26/21.
//

import UIKit
import Foundation
import Parse

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordRe: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var displayPicture: UIImageView!
    
    private var forEdit: Bool = false
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makePictureRounded(picture: displayPicture)
    }

}

//MARK:- IBOutlet Functions
extension SignUpViewController {
    //Add user to table
    @IBAction func signUp(_ sender: UIButton) {
        if(lastName.text!.isEmpty || email.text!.isEmpty || password.text!.isEmpty || phone.text!.isEmpty){
            let alert = networkErrorAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let user = PFUser()
            if(password.text == passwordRe.text){
                //Using email as username
                user.username = email.text
                user.email = email.text
                user.password = password.text
                user["fName"] = firstName.text
                user["lName"] = lastName.text
                user["phone"] = Int(phone.text!)
                user["lastLogin"] = NSDate()
                
                //for display image
                let imageData = displayPicture.image!.pngData()
                let imageName = makeImageName(self.email.text!)
                let imageFile = PFFileObject(name: imageName, data: imageData!)
                user["displayImage"] = imageFile
                
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
    }
    
    //Upload Photo
    @IBAction func choosePhoto(_ sender: Any) {
        showAlert()
    }
    
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK:- UIImagePickerViewDelegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Show alert to selected the media source type.
    private func showAlert() {
        
        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true) { [weak self] in
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            //Setting image to your image view
            self?.displayPicture.image = image
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
