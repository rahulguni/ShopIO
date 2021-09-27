import UIKit
import Parse

/**/
/*
class AddressViewController

DESCRIPTION
        This class is a UIViewController that controls Address.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        06/25/2021
 
*/
/**/

class AddressViewController: UIViewController {

    @IBOutlet weak var line_1: UITextField!
    @IBOutlet weak var line_2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var phone_sec: UITextField!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subtitle: UITextField!
    @IBOutlet weak var primaryAddress: UISwitch!
    @IBOutlet weak var doThisLaterButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    let states = State()                    //For State options in UIPicker
    private var shopId: String?             //For Shop Address
    private var editMode: forAddress?       //To render view for edit/add
    private var addressId: String?          //to update address for edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.hideKeyboardWhenTappedAround() 
        
        let statePicker = UIPickerView()
        statePicker.delegate = self
        state.inputView = statePicker
        // Do any additional setup after loading the view.
        
        if let user = currentUser {
            if let name = user.value(forKey: "fName"){
                titleLabel.text = "Welcome, \(name)"
            }
            if let phone = user.value(forKey: "phone") {
                phone_sec.placeholder! = String(format: "%@", phone as! CVarArg)
            }
        }
        
        if(self.editMode == forAddress.forShop) {
            subtitle.text = "Use my Primary Address for my shop."
            subtitle.textAlignment = NSTextAlignment.left
            primaryAddress.isOn = false
            primaryAddress.isHidden = false
            doThisLaterButton.isHidden = true
        }
        if(self.editMode == forAddress.forEdit || self.editMode == forAddress.forShopEdit) {
            saveButton.isHidden = true
            updateButton.isHidden = false
            subtitle.text = "Edit your address and click on update"
            fillformForEdit()
        }
        if(self.editMode == forAddress.forAddNewShop) {
            subtitle.text = "Fill out the details below to add a new address"
        }

    }

}

//MARK: - IBOutlet Functions
extension AddressViewController {
    
    /**/
    /*
    @IBAction func saveButtonPressed(_ sender: UIButton)

    NAME

            saveButtonPressed - Action for Save Button click.

    DESCRIPTION

            This function first checks if the required fields are typed in. According to the editMode variable,
            a new address is saved for user/shop. Before saving address, the a geoQuery is queried to determine
            validity of the address. After check, the address is saved to either Address table or Shop_Address
            table depending on editMode. It also adds a geoLocation coordinate to the Shop table for faster query.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/25/2021

    */
    /**/
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if(line_1.text!.isEmpty || city.text!.isEmpty || zip.text!.isEmpty || state.text!.isEmpty) {
            let alert = customNetworkAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        
        else if(isValidPhone(phone: self.phone_sec.text!)){
            if(self.editMode == forAddress.forShop){
                let address = fillForm(className: ShopIO.Shop_Address().shopAddressTableName)
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(Address(address: address).getFullAddress()) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            //save shop geoPoints in Shop Database
                            let shopQuery = PFQuery(className: ShopIO.Shop().tableName)
                            shopQuery.whereKey(ShopIO.Shop().objectId, equalTo: self.shopId!)
                            shopQuery.getFirstObjectInBackground{(shop, error) in
                                if let shop = shop {
                                    shop[ShopIO.Shop().geoPoints] = PFGeoPoint(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                                    shop.saveInBackground()
                                }
                                else {
                                    let alert = customNetworkAlert(title: "Unable to save address.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            address[ShopIO.Shop().geoPoints] = PFGeoPoint(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                            address.saveInBackground {(success, error) in
                                if(success) {
                                    self.performSegue(withIdentifier: "reloadMyShop", sender: self)
                                }
                                else {
                                    let alert = customNetworkAlert(title: "Could not save Address", errorString: "Check connection and try again.")
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    else{
                        let alert = customNetworkAlert(title: "Cannot find location", errorString: "Please enter a valid location.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let address = fillForm(className: ShopIO.Address().addressTableName)
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(Address(address: address).getFullAddress()) { (placemarks, error) in
                    if error == nil {
                        if let placemark = placemarks?[0] {
                            address[ShopIO.Address().geoPoints] = PFGeoPoint(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                            address.saveInBackground {(success, error) in
                                if(success) {
                                    self.performSegue(withIdentifier: "reloadAccount", sender: self)
                                } else {
                                    let alert = customNetworkAlert(title: "Could not save Address", errorString: "Check connection and try again.")
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    else{
                        let alert = customNetworkAlert(title: "Cannot find location", errorString: "Please enter a valid location.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let alert = customNetworkAlert(title: "Error signing up", errorString: "Invalid Phone: Phone number must be exactly 10 digits long.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    /* @IBAction func saveButtonPressed(_ sender: UIButton) */
    
    /**/
    /*
    @IBAction func updateButtonPressed(_ sender: Any)

    NAME

            updateButtonPressed - Action for Update Button click.

    DESCRIPTION

            This function first checks if the required fields are typed in. According to the editMode variable,
            an existing address is updated for user/shop. Before saving address, the a geoQuery is queried to determine
            validity of the address. After check, the address is saved to either Address table or Shop_Address
            table depending on editMode. It also updates the geoLocation coordinate to the Shop table for faster query.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/25/2021

    */
    /**/
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        if(line_1.text!.isEmpty || city.text!.isEmpty || zip.text!.isEmpty || state.text!.isEmpty || phone_sec.text!.isEmpty) {
            let alert = customNetworkAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        else if(isValidPhone(phone: self.phone_sec.text!)){
            let query: PFQuery<PFObject>
            if(self.editMode == forAddress.forShopEdit) {
                query = PFQuery(className: ShopIO.Shop_Address().shopAddressTableName)
            }
            else {
                query = PFQuery(className: ShopIO.Address().addressTableName)
            }
            query.getObjectInBackground(withId: self.addressId!){(address: PFObject?, error: Error?) in
                if let error = error {
                    let alert = customNetworkAlert(title: "Error updating address.", errorString: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                }
                else if let address = address {
                    address[ShopIO.Address().line1] = self.line_1.text
                    address[ShopIO.Address().line2] = self.line_2.text
                    address[ShopIO.Address().city] = self.city.text
                    address[ShopIO.Address().state] = self.state.text
                    address[ShopIO.Address().zip] = self.zip.text
                    address[ShopIO.Address().phone] = Int(self.phone_sec.text!)
                    
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(Address(address: address).getFullAddress()) { (placemarks, error) in
                        if error == nil {
                            if let placemark = placemarks?[0] {
                                //update address in shop geopoints
                                if(self.editMode == forAddress.forShopEdit){
                                    let shopQuery = PFQuery(className: ShopIO.Shop().tableName)
                                    shopQuery.whereKey(ShopIO.Shop().objectId, equalTo: self.shopId!)
                                    shopQuery.getFirstObjectInBackground{(shop, error) in
                                        if let shop = shop {
                                            shop[ShopIO.Shop().geoPoints] = PFGeoPoint(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                                            shop.saveInBackground()
                                        }
                                        else {
                                            let alert = customNetworkAlert(title: "Unable to save address.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                }
                                address[ShopIO.Address().geoPoints] = PFGeoPoint(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                                address.saveInBackground {(success, error) in
                                    if(success) {
                                        self.performSegue(withIdentifier: "reloadAccount", sender: self)
                                    }
                                    else {
                                        let alert = customNetworkAlert(title: "Could not update Address", errorString: "Check connection and try again.")
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                        else{
                            let alert = customNetworkAlert(title: "Cannot find location", errorString: "Please enter a valid location.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        else {
            let alert = customNetworkAlert(title: "Error signing up", errorString: "Invalid Phone: Phone number must be exactly 10 digits long.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    /* @IBAction func updateButtonPressed(_ sender: Any) */
    
    //Action for Do this later button click
    @IBAction func doThisLaterButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reloadAccount", sender: self)
    }

    /**/
    /*
    @IBAction func primaryAddressSwitch(_ sender: UISwitch)

    NAME

            primaryAddressSwitch - Action for Primary Address switch.

    DESCRIPTION

            This function first queries Address table using the current user's objectId and fills in UITextfields
            with the user's primary address if the switch is on. When turned off, it clears all field.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/25/2021

    */
    /**/
    
    @IBAction func primaryAddressSwitch(_ sender: UISwitch) {
        if(primaryAddress.isOn) {
            let query = PFQuery(className: ShopIO.Address().addressTableName)
            query.whereKey(ShopIO.Address().userId, equalTo: currentUser!.objectId!)
            query.whereKey(ShopIO.Address().isDefault, equalTo: true)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if let error = error {
                    // The query succeeded but no matching result was found
                    let alert = customNetworkAlert(title: "No Primary address", errorString: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                    self.primaryAddress.isOn = false
                }
                else if let object = object {
                    let address = Address(address: object)
                    // The query succeeded with a matching result
                    self.line_1.text = address.getLine1()
                    self.line_2.text = address.getLine2()
                    self.city.text = address.getCity()
                    self.state.text = address.getState()
                    self.zip.text = address.getZip()
                    self.phone_sec.text = address.getPhone()!.description
                }
            }
        }
        else{
            line_1.text = ""
            line_2.text = ""
            city.text = ""
            state.text = ""
            zip.text = ""
        }
    }
    /* @IBAction func primaryAddressSwitch(_ sender: UISwitch) */
}

//MARK: - Display Functions
extension AddressViewController {
    
    //Setter function for editMode of current view, passed on from previous view controller.
    func setEditMode(editMode: forAddress) {
        self.editMode = editMode
    }
    
    //Setter function for shopId if address is presented for shop, passed on from previous view controller.
    func setShopId(shopId: String) {
        self.shopId = shopId
    }
    
    //Setter function to set up current Address's objectId if the view is called for edit, passed on from previous view controller.
    func setAddressId(addressId: String) {
        self.addressId = addressId
    }
    
    /**/
    /*
    private func fillForm(className forClass: String) -> PFObject

    NAME

            fillForm - Get all required parameters for Address object
     
    SYNOPSIS
           
            fillForm(className forClass: String)
                forClass    --> Either Address or Shop_Address, depending on forEdit.

    DESCRIPTION

            This function creates a PFObject with all the UITextField parameters and returns an object ready to be inserted to
            Address or Shop_Address table.

    RETURNS

            PFObject    --> Ready to be uploaded to server.

    AUTHOR

            Rahul Guni

    DATE

            06/25/2021

    */
    /**/
    
    private func fillForm(className forClass: String) -> PFObject {
        let address = PFObject(className: forClass)
        if(forClass == ShopIO.Shop_Address().shopAddressTableName){
            address[ShopIO.Shop_Address().shopId] = shopId!
        }
        else {
            address[ShopIO.Address().userId] = currentUser?.objectId!
        }
        address[ShopIO.Address().line1] = line_1.text
        
        if line_2.text != "" {
            address[ShopIO.Address().line2] = line_2.text
        } else {
            address[ShopIO.Address().line2] = ""
        }
        
        address[ShopIO.Address().city] = city.text
        address[ShopIO.Address().state] = state.text
        address[ShopIO.Address().zip] = zip.text
        address[ShopIO.Address().country] = "USA"
        if(self.editMode != forAddress.forAddNewShop) {
            address[ShopIO.Address().isDefault] = true
        }
        else{
            address[ShopIO.Address().isDefault] = false
        }
        
        if phone_sec.text != "" {
            address[ShopIO.Address().phone] = Int(phone_sec.text!)
        } else {
            address[ShopIO.Address().phone] = currentUser?.value(forKey: "phone") as! Int
        }
        
        return address
    }
    /* private func fillForm(className forClass: String) -> PFObject */
    
    /**/
    /*
    private func fillformForEdit()

    NAME

            fillformForEdit - Fills the UITextField with address object values.

    DESCRIPTION

            This function first queries the Address or Shop_Address table with addressId passed from
            previous view controller. Then once the object is fetched, UITextField parameters are
            filled with those values.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            06/25/2021

    */
    /**/
    
    private func fillformForEdit(){
        var query: PFQuery<PFObject>?
        if(self.editMode == forAddress.forShopEdit) {
            query = PFQuery(className: ShopIO.Shop_Address().shopAddressTableName)
        }
        else {
            query = PFQuery(className: ShopIO.Address().addressTableName)
        }
        
        query!.whereKey(ShopIO.Address().objectId, equalTo: self.addressId!)
        query!.getFirstObjectInBackground{(object, error) in
            if let object = object {
                let address = Address(address: object)
                self.line_1.text = address.getLine1()
                self.line_2.text = address.getLine2()
                self.city.text = address.getCity()
                self.state.text = address.getState()
                self.zip.text = address.getZip()
                self.phone_sec.text = address.getPhone()!.description
            }
        }
    }
    /* private func fillformForEdit() */
}

//MARK: - Picker Functions
extension AddressViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.stateNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states.stateNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        state.text = states.stateFull[row]
    }
    
}
