import UIKit
import Parse

/**/
/*
class AddShopViewController

DESCRIPTION
        This class is a UIViewController that controls AddShop.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        06/29/2021
 
*/
/**/

class AddShopViewController: UIViewController {

    //IBOutlet Elements
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var shopSlogan: UITextField!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subTitleLabel: UITextField!
    @IBOutlet weak var shippingLabel: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    private var myShop: Shop?       //New Shop Object
    var forEdit: Bool = false       //boolean to render view for edit or add new shop.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
        self.isModalInPresentation = true
        self.shippingLabel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(forEdit){
            loadEditShop()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //function to make address controller store address in shop database for shops
        if(segue.identifier! == "toAddress") {
            let destination = segue.destination as! AddressViewController
            destination.setEditMode(editMode: forAddress.forShop)
            destination.setShopId(shopId: myShop!.getShopId())
        }
    }
}

//MARK:- IBOutlet Functions
extension AddShopViewController {
    
    //Action for Continue button click
    @IBAction func continueButtonPressed(_ sender: Any) {
        if (shopName.text!.isEmpty || shippingLabel.text!.isEmpty || self.shopImage.image == nil){
            let alert = customNetworkAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        
        else {
            if(myShop == nil) {
                saveShop()
            }
            else {
                updateShop()
            }
        }
    }
    
    //Action for back button click
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Action for add photo click
    @IBAction func addPhoto(_ sender: Any) {
        self.showAlert()
    }
}

//MARK: - Display Functions
extension AddShopViewController {
    
    //setter function to set up current shop for edit, passed from previous view controller.
    func setShop(shop myShop: Shop) {
        self.myShop = myShop
    }
    
    /**/
    /*
    private func loadEditShop()

    NAME

           loadEditShop - Load View if forEdit is true

    DESCRIPTION

            This function fills the UITextFields with current Shop's parameters and allows user to update the shop

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/29/2021

    */
    /**/
    
    private func loadEditShop(){
        titleLabel.text = "Welcome"
        subTitleLabel.text = "Modify the fields below and press update."
        let shopName = myShop?.getShopTitle()
        let shopSlogan = myShop?.getShopSlogan()
        let shopImagecover = myShop?.getShopImage()
        let shippingCost = myShop?.getShippingCostAsString()
        let tempImage = shopImagecover
        tempImage!.getDataInBackground{(imageData: Data?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let imageData = imageData {
                self.shopImage.image = UIImage(data: imageData)
            }
        }
        self.shopName.text = shopName
        self.shopSlogan.text = shopSlogan
        self.shippingLabel.text = shippingCost
        self.continueButton.setTitle("Update", for: .normal)
    }
    /* private func loadEditShop() */
    
    /**/
    /*
    private func saveShop()

    NAME

           saveShop - Adds new shop

    DESCRIPTION

            This function saves a new shop in Shop table with parameters from UITextfields.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/29/2021

    */
    /**/
    
    private func saveShop(){
        let shop = PFObject(className: ShopIO.Shop().tableName)

        shop[ShopIO.Shop().userId] = currentUser!.objectId!
        shop[ShopIO.Shop().title] = shopName.text
        shop[ShopIO.Shop().slogan] = shopSlogan.text
        shop[ShopIO.Shop().shippingCost] = Double(shippingLabel.text!)
        let imageData = shopImage.image!.jpegData(compressionQuality: 0.5)
        
        //for image naming
        
        let imageName = makeImageName(currentUser!.objectId!)
        let imageFile = PFFileObject(name: imageName, data:imageData!)
        shop[ShopIO.Shop().shopImage] = imageFile
        
        shop.saveInBackground{(success, error) in
            if(success) {
                self.myShop = Shop(shop: shop)
                self.performSegue(withIdentifier: "toAddress", sender: self)
            }
            else{
                let alert = customNetworkAlert(title: "Unable to save shop.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func saveShop() */
    
    /**/
    /*
    private func updateShop()

    NAME

           updateShop - Adds new shop

    DESCRIPTION

            This function first fetches the shop from current user's objectId and updates it according to current UITextFields parameteres.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/29/2021

    */
    /**/
    
    private func updateShop() {
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.getObjectInBackground(withId: myShop!.getShopId()) { (shop: PFObject?, error: Error?) in
            if let myShop = shop {
                myShop[ShopIO.Shop().title] = self.shopName.text
                myShop[ShopIO.Shop().slogan] = self.shopSlogan.text
                myShop[ShopIO.Shop().shippingCost] = Double(self.shippingLabel.text!)
                let imageData = self.shopImage.image!.jpegData(compressionQuality: 0.5)
                let imageName = makeImageName(myShop.objectId!)
                let imageFile = PFFileObject(name: imageName, data:imageData!)
                myShop[ShopIO.Shop().shopImage] = imageFile
                myShop.saveInBackground{(success, error) in
                    if(success) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        let alert = customNetworkAlert(title: "Unable to update shop.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    /* private func updateShop() */
}

//MARK:- UIImagePickerViewDelegate
extension AddShopViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        //Check if source type available
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
            self?.shopImage.image = image
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITextFieldDelegate
extension AddShopViewController: UITextFieldDelegate {
    
    /**/
    /*
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool

    NAME

            textField - Action for textField Change

    DESCRIPTION

            This function checks the price UITextField so that there is only one decimal and 2 digits after decimal.

    RETURNS

            True if price is in correct format, else false

    AUTHOR

            Rahul Guni

    DATE

            07/17/2021

    */
    /**/
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
    /* func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool*/
}

