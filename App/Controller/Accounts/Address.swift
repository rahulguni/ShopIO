//
//  Address.swift
//  App
//
//  Created by Rahul Guni on 6/25/21.
//

import UIKit
import Parse

class Address: UIViewController {

    @IBOutlet weak var line_1: UITextField!
    @IBOutlet weak var line_2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var phone_sec: UITextField!
    @IBOutlet weak var titleLabel: UITextField!
    
    let states = State()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statePicker = UIPickerView()
        statePicker.delegate = self;
        state.inputView = statePicker;
        // Do any additional setup after loading the view.
        
        if let user = currentUser {
            if let name = user.value(forKey: "fName"){
                titleLabel.text = "Welcome, \(name)"
            }
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let address = PFObject(className: "Address")
        address["userId"] = currentUser?.objectId!
        address["line_1"] = line_1.text
        
        if line_2.text != "" {
            address["line_2"] = line_2.text
        } else {
            address["line_2"] = ""
        }
        
        address["city"] = city.text
        address["state"] = state.text
        address["zip"] = Int(zip.text!)
        address["country"] = "USA"
        address["isDefault"] = true;
        
        if phone_sec.text != "" {
            address["phone"] = Int(phone_sec.text!)
        } else {
            address["phone"] = currentUser?.value(forKey: "phone") as! Int
        }
        address.saveInBackground {(success, error) in
            if(success) {
                self.performSegue(withIdentifier: "reloadAccount", sender: self)
            } else {
                let alert = networkErrorAlert(title: "Could not save Address", errorString: "Check connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func doThisLaterButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "reloadAccount", sender: self)
    }
    
}

//MARK: - Picker Functions

extension Address: UIPickerViewDelegate, UIPickerViewDataSource{
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
