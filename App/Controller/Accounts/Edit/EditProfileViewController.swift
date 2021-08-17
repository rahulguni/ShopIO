//
//  EditProfileViewController.swift
//  App
//
//  Created by Rahul Guni on 8/2/21.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController {
    @IBOutlet weak var editShopButton: UIButton!
    @IBOutlet weak var displayPicture: UIImageView!
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!

    private var myShop: Shop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        modifyButton(button: editShopButton)
        fillForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToEditShop") {
            let destination = segue.destination as! AddShopViewController
            if(myShop != nil) {
                destination.forEdit = true
                destination.setShop(shop: myShop!)
            }
        }
    }
    
}

//MARK:- IBOutlet Functions
extension EditProfileViewController {
    @IBAction func editShopPressed(_ sender: Any) {
        let query = PFQuery(className: "Shop")
        query.whereKey("userId", contains: currentUser!.objectId)
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let object = object {
                // The query succeeded with a matching result
                self.myShop = Shop(shop: object)
            }
            self.performSegue(withIdentifier: "goToEditShop", sender: self)
        }
    }
    
    @IBAction func updateProfilePressed(_ sender: Any) {
        if(self.fName.text == nil || self.lName.text == nil) {
            let alert = networkErrorAlert(title: "Cannot Update Profile", errorString: "Please fill out all fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let query = PFUser.query()
            query?.whereKey("objectId", contains: currentUser!.objectId!)
            query?.getFirstObjectInBackground{(user, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let user = user {
                    user["fName"] = self.fName.text!
                    user["lName"] = self.lName.text!
                    
                    let imageData = self.displayPicture.image?.pngData()
                    let imageName = makeImageName(currentUser!.value(forKey: "email") as! String)
                    let imageFile = PFFileObject(name: imageName, data: imageData!)
                    user["displayImage"] = imageFile
                    
                    user.saveInBackground {(success, error) in
                        if(success) {
                            currentUser!["fName"] = self.fName.text!
                            currentUser!["lName"] = self.lName.text!
                            currentUser!["displayImage"] = imageFile
                            let alert = networkErrorAlert(title: "Successfully updated profile", errorString: "Your profile has been updated")
                            self.present(alert, animated: true, completion: nil)
                            self.fillForm()
                        }
                        else {
                            let alert = networkErrorAlert(title: "Could not update profile", errorString: "Please try again later.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        showAlert()
    }
}

//MARK:- Display Functions
extension EditProfileViewController {
    private func fillForm() {
        makePictureRounded(picture: self.displayPicture)
        self.fName.text = currentUser!.value(forKey: "fName") as? String
        self.lName.text = currentUser!.value(forKey: "lName") as? String
        
        let displayPic = currentUser!.value(forKey: "displayImage") as? PFFileObject
        displayPic?.getDataInBackground{(imageData: Data?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let imageData = imageData {
                self.displayPicture.image = UIImage(data: imageData)
            }
        }
    }
}

//MARK:- UIImagePickerViewDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
