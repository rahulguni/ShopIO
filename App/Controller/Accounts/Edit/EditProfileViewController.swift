//
//  EditProfileViewController.swift
//  App
//
//  Created by Rahul Guni on 8/2/21.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController {
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var editShopButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var myShop: Shop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let myButtons: [UIButton] = [editShopButton,editProfileButton]
        modifyButtons(buttons: myButtons)
        let name = currentUser!.value(forKey: "fName") as! String
        titleLabel.text = "Welcome, \(name)"
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
    
    @IBAction func editProfilePressed(_ sender: Any) {
        //self.performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    

}
