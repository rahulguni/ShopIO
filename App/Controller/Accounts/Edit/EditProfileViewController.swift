import UIKit
import Parse

/**/
/*
class EditProfileViewController

DESCRIPTION
        This class is a UIViewController that controls EditProfile.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        08/02/2021
 
*/
/**/

class EditProfileViewController: UIViewController {
    
    //IBOutlet elements
    @IBOutlet weak var editShopButton: UIButton!
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var displayPicture: UIImageView!
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var deliveryAddressLabel: UITextView!
    
    //controller variables
    private var myShop: Shop?                           //current user's shop
    private var currUser: User?                         //current user
    private var forOrder: Bool = false                  //to determine if view is presented from edit profile or order view
    private var deliveryAddress: Address?               //address object is delivery is true for order, only available when view is presented from Order view.
    private var userLocation: CLLocationCoordinate2D?   //geoLocation to track user's location to view customer in map if view is called from Order view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        modifyButton(button: editShopButton)
        self.deliveryAddressLabel.layer.borderWidth = 1.0
        self.deliveryAddressLabel.layer.borderColor = UIColor.black.cgColor
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
        
        if(segue.identifier! == "goToMaps"){
            let destination = segue.destination as! MapViewController
            destination.setCurrProfile(user: self.currUser!)
            destination.setLocation(coordinates: self.userLocation!)
        }
    }
}

//MARK:- IBOutlet Functions
extension EditProfileViewController {
    
    /**/
    /*
    @IBAction func editShopPressed(_ sender: Any)

    NAME

            editShopPressed - Action for edit shop button click

    DESCRIPTION

            This function checks for shop of the current user and segues to AddShopViewController. If the user has a shop,
            the next view is rendered for edit otherwise, it is rendered for add new shop/
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
    @IBAction func editShopPressed(_ sender: Any) {
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().userId, contains: currentUser!.objectId)
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let object = object {
                // The query succeeded with a matching result
                self.myShop = Shop(shop: object)
            }
            self.performSegue(withIdentifier: "goToEditShop", sender: self)
        }
    }
    /* @IBAction func editShopPressed(_ sender: Any)*/
    
    /**/
    /*
    @IBAction func goToUserMap(_ sender: Any)

    NAME

            goToUserMap - Action for user's delivery location label click.

    DESCRIPTION

            This function queries the Address table for current order's delivery address and segues to MapViewController
            flying right into user's delivery location.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
    @IBAction func goToUserMap(_ sender: Any) {
        let query = PFQuery(className: ShopIO.Address().addressTableName)
        query.whereKey(ShopIO.Address().userId, equalTo: self.currUser!.getObjectId())
        query.getFirstObjectInBackground{(shopAddress, error) in
            if let shopAddress = shopAddress {
                let address = Address(address: shopAddress)
                //find CLLocationDegrees of Shop Address
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address.getFullAddress()) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            self.userLocation = placemark.location!.coordinate
                            self.performSegue(withIdentifier: "goToMaps", sender: self)
                        }
                    }
                    else{
                        let alert = customNetworkAlert(title: "Cannot find User Location", errorString: "The user does not have a valid location. Please talk to the user.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    /* @IBAction func goToUserMap(_ sender: Any) */
    
    /**/
    /*
    @IBAction func updateProfilePressed(_ sender: Any)

    NAME

            updateProfilePressed - Action for update Profile button click.

    DESCRIPTION

            This function queries the User table and updates the fetched object with updated parameters from UITextFields along with image update.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
    @IBAction func updateProfilePressed(_ sender: Any) {
        if(self.fName.text == nil || self.lName.text == nil) {
            let alert = customNetworkAlert(title: "Cannot Update Profile", errorString: "Please fill out all fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let query = PFUser.query()
            query?.whereKey(ShopIO.User().objectId, equalTo: currentUser!.objectId!)
            query?.getFirstObjectInBackground{(user, error) in
                if let _ = error {
                    let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                } else if let user = user {
                    user[ShopIO.User().fName] = self.fName.text!
                    user[ShopIO.User().lName] = self.lName.text!
                    
                    let imageData = self.displayPicture.image?.pngData()
                    let imageName = makeImageName(currentUser!.objectId!)
                    let imageFile = PFFileObject(name: imageName, data: imageData!)
                    user[ShopIO.User().displayImage] = imageFile
                    
                    user.saveInBackground {(success, error) in
                        if(success) {
                            currentUser![ShopIO.User().fName] = self.fName.text!
                            currentUser![ShopIO.User().lName] = self.lName.text!
                            currentUser![ShopIO.User().displayImage] = imageFile
                            let alert = customNetworkAlert(title: "Successfully updated profile", errorString: "Your profile has been updated")
                            self.present(alert, animated: true, completion: nil)
                            self.fillForm()
                        }
                        else {
                            let alert = customNetworkAlert(title: "Could not update profile", errorString: "Please try again later.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    /* @IBAction func updateProfilePressed(_ sender: Any) */
    
    //Action for upload photo button click
    @IBAction func uploadPhoto(_ sender: Any) {
        showAlert()
    }
}

//MARK:- Display Functions
extension EditProfileViewController {
    
    //Setter function that sets up current user, passed on from previous view controller (OrderViewController/AccountViewController)
    func setUser(currUser: User) {
        self.currUser = currUser
    }
    
    //Setter function for myOrders boolean, passed on from previous view controller (OrderViewController)
    func setForOrder(bool: Bool) {
        self.forOrder = bool
    }
    
    //Setter function for delivery address if pickUp is false for order, passed on from previous view controller (OrderViewController)
    func setDeliveryAddress(address: Address) {
        self.deliveryAddress = address
    }
    
    /**/
    /*
    private func getUser(currUser: User)

    NAME

            getUser - Gets current User's details
     
    SYNOPSIS
           
            getUser(currUser: User)
                currUser      --> User object to find full name

    DESCRIPTION

            This function takes in a user object and sets name labels according to user's name. It also performs a query to get current
            user's display picture on the view.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
    private func getUser(currUser: User) {
        self.fName.text = currUser.getFname()
        self.lName.text = currUser.getLname()
        
        let displayPic = currUser.getImage()
        displayPic.getDataInBackground{(imageData: Data?, error: Error?) in
            if let imageData = imageData {
                self.displayPicture.image = UIImage(data: imageData)
            }
        }
    }
    /* private func getUser(currUser: User) */
    
    /**/
    /*
    private func fillForm()

    NAME

            fillForm - Edits the view for edit/order

    DESCRIPTION

            This function checks the forOrder boolean and renders the view for order if it is true and for edit if it is false.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
    private func fillForm() {
        makePictureRounded(picture: self.displayPicture)
        if(forOrder) {
            self.fName.isUserInteractionEnabled = false
            self.lName.isUserInteractionEnabled = false
            self.displayPicture.isUserInteractionEnabled = false
            self.editShopButton.isHidden = true
            self.updateProfileButton.isHidden = true
            if let address = deliveryAddress {
                self.deliveryAddressLabel.isHidden = false
                self.deliveryAddressLabel.text = "\(address.getAddressForOrder())"
            }
            getUser(currUser: currUser!)
        }
        else {
            getUser(currUser: User(userID: currentUser!))
        }
    }
    /* private func fillForm() */
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
            imagePickerController.allowsEditing = true
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
