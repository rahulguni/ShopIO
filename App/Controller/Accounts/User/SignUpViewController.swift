import UIKit
import Foundation
import Parse

/**/
/*
class SignUpViewController

DESCRIPTION
        This class is a UIViewController that controls SignUp.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        04/26/2021
 
*/
/**/

class SignUpViewController: UIViewController {
    
    //IBOutlet Elements
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordRe: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var displayPicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makePictureRounded(picture: displayPicture)
        self.hideKeyboardWhenTappedAround() 
    }

}

//MARK:- IBOutlet Functions
extension SignUpViewController {
    
    /**/
    /*
    @IBAction func signUp(_ sender: UIButton)

    NAME

           signUp - Adds a new user to User's table

    DESCRIPTION

            This function first checks if all required fields are filled up. Then, it adds the user to User's table and segues to
            AddressViewController to add a primary address for the user. This function also checks if the password and phone number
            typed passes the criteria.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            04/26/2021

    */
    /**/
    
    @IBAction func signUp(_ sender: UIButton) {
        if(lastName.text!.isEmpty || email.text!.isEmpty || password.text!.isEmpty || phone.text!.isEmpty || self.displayPicture.image == nil){
            let alert = customNetworkAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        else if(isValidPhone(phone: self.phone.text!) && isValidPassword(password: self.password.text!)){
            let user = PFUser()
            if(password.text == passwordRe.text){
                //Using email as username
                user.username = email.text
                user.email = email.text
                user.password = password.text
                user[ShopIO.User().fName] = firstName.text
                user[ShopIO.User().lName] = lastName.text
                user[ShopIO.User().phone] = Int(phone.text!)
                user[ShopIO.User().lastLogin] = NSDate()
                
                //for display image
                let imageData = displayPicture.image!.jpegData(compressionQuality: 0.5)
                let imageName = makeImageName(self.email.text!)
                let imageFile = PFFileObject(name: imageName, data: imageData!)
                user[ShopIO.User().displayImage] = imageFile
                
                user.signUpInBackground {
                    (succeeded: Bool, error: Error?) -> Void in
                    if let error = error {
                      let errorString = error.localizedDescription
                      // Show the errorString somewhere and let the user try again.
                        let alert = customNetworkAlert(title: "Error Signing Up", errorString: errorString)
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
                let alert = customNetworkAlert(title: "Error Signing Up", errorString: "Passwords do not match. Please try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            var errorMsg: String?
            if(!isValidPassword(password: self.password.text!) && !isValidPhone(phone: self.phone.text!)) {
                errorMsg = "Invalid password: Password should be atleast 8 characters long inlcuding a big number and a letter. \nInvalid Phone: Phone number must be exactly 10 digits long."
            }
            else if(!isValidPassword(password: self.password.text!)) {
                errorMsg = "Invalid password: Password should be atleast 8 characters long inlcuding a big number and a letter."
            }
            else if(!isValidPhone(phone: self.phone.text!)) {
                errorMsg = "Invalid Phone: Phone number must be exactly 10 digits long."
            }
            let alert = customNetworkAlert(title: "Error signing up", errorString: errorMsg!)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    /* @IBAction func signUp(_ sender: UIButton) */
    
    //Action for click on photo to add a new one
    @IBAction func choosePhoto(_ sender: Any) {
        showAlert()
    }
    
    //Action for back button click
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- General functions
extension SignUpViewController {
    
    /**/
    /*
    private func isValidPassword(password: String) -> Bool

    NAME

           isValidPassword - Checks password strength

    DESCRIPTION

            This function checks if the string passed from password textfield matches the following criteria:
            Contains atleast one big letter, a number and is of length of a minimum 8 characters.

    RETURNS

            True    -> Password matches regex
            False   -> Password does not match regex

    AUTHOR

            Rahul Guni

    DATE

            04/26/2021

    */
    /**/
    
    private func isValidPassword(password: String) -> Bool {
        let securedPassword = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        return securedPassword.evaluate(with: password)
    }
    /* private func isValidPassword(password: String) -> Bool */
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
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true) { [weak self] in
            guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
            //Setting image to your image view
            self?.displayPicture.image = image
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
