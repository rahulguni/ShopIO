//
//  Address.swift
//  App
//
//  Created by Rahul Guni on 6/25/21.
//

import UIKit
import Parse

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
    
    let states = State()
    
    /* Since Address gets called from different places, declare a variable to perform
      segue and add address accordingly. */
    //To save address
    var forShop : Bool = false
    var forEdit: Bool = false
    var shopId: String?
    
    //To Update address
    var forShopEdit: Bool = false
    var addressId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
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
        
        if(forShop) {
            subtitle.text = "Use my Primary Address for my shop."
            subtitle.textAlignment = NSTextAlignment.left
            primaryAddress.isOn = false
            primaryAddress.isHidden = false
            doThisLaterButton.isHidden = true
        }
        if(forEdit) {
            saveButton.isHidden = true
            updateButton.isHidden = false
            subtitle.text = "Edit your address and click on update"
            fillformForEdit()
        }
    }

}

//MARK: - IBOutlet Functions
extension AddressViewController {
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if(line_1.text!.isEmpty || city.text!.isEmpty || zip.text!.isEmpty || state.text!.isEmpty) {
            let alert = networkErrorAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        
        else {
            if(forShop){
                let address = fillForm(className: "Shop_Address")
                address.saveInBackground {(success, error) in
                    if(success) {
                        self.performSegue(withIdentifier: "reloadMyShop", sender: self)
                    } else {
                        let alert = networkErrorAlert(title: "Could not save Address", errorString: "Check connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let address = fillForm(className: "Address")
                address.saveInBackground {(success, error) in
                    if(success) {
                        self.performSegue(withIdentifier: "reloadAccount", sender: self)
                    } else {
                        let alert = networkErrorAlert(title: "Could not save Address", errorString: "Check connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        if(line_1.text!.isEmpty || city.text!.isEmpty || zip.text!.isEmpty || state.text!.isEmpty || phone_sec.text!.isEmpty) {
            let alert = networkErrorAlert(title: "Error signing in", errorString: "One or more entry field missing. Please fill out all the details.")
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let query: PFQuery<PFObject>
            if(forShopEdit) {
                query = PFQuery(className: "Shop_Address")
            }
            else {
                query = PFQuery(className: "Address")
            }
            query.getObjectInBackground(withId: self.addressId!){(address: PFObject?, error: Error?) in
                if let error = error {
                    let alert = networkErrorAlert(title: "Error updating address.", errorString: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                }
                else if let address = address {
                    address["line_1"] = self.line_1.text
                    address["line_2"] = self.line_2.text
                    address["city"] = self.city.text
                    address["state"] = self.state.text
                    address["zip"] = self.zip.text
                    address["phone"] = Int(self.phone_sec.text!)
                    address.saveInBackground{(success, error) in
                        if(success) {
                            self.dismiss(animated: true, completion: nil)
                        }
                        else{
                            let alert = networkErrorAlert(title: "Error updating address.", errorString: "Error updating address. Please try later.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func doThisLaterButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reloadAccount", sender: self)
    }
    
    //function to fill address field with primary options if switched on
    @IBAction func primaryAddressSwitch(_ sender: UISwitch) {
        if(primaryAddress.isOn) {
            let query = PFQuery(className: "Address")
            query.whereKey("userId", equalTo: currentUser!.objectId!)
            query.whereKey("isDefault", equalTo: true)
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if let error = error {
                    // The query succeeded but no matching result was found
                    let alert = networkErrorAlert(title: "No Primary address", errorString: error.localizedDescription)
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
}

//MARK: - Display Functions
extension AddressViewController {
    private func fillForm(className forClass: String) -> PFObject {
        let address = PFObject(className: forClass)
        if(forClass == "Shop_Address"){
            address["shopId"] = shopId!
        }
        else {
            address["userId"] = currentUser?.objectId!
        }
        address["line_1"] = line_1.text
        
        if line_2.text != "" {
            address["line_2"] = line_2.text
        } else {
            address["line_2"] = ""
        }
        
        address["city"] = city.text
        address["state"] = state.text
        address["zip"] = zip.text
        address["country"] = "USA"
        address["isDefault"] = true;
        
        if phone_sec.text != "" {
            address["phone"] = Int(phone_sec.text!)
        } else {
            address["phone"] = currentUser?.value(forKey: "phone") as! Int
        }
        
        return address
    }
    
    private func fillformForEdit(){
        var query: PFQuery<PFObject>?
        if(forShopEdit) {
            query = PFQuery(className: "Shop_Address")
        }
        else {
            query = PFQuery(className: "Address")
        }
        
        query!.whereKey("objectId", contains: addressId!)
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