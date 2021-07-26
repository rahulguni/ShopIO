//
//  AddProductExtraViewController.swift
//  App
//
//  Created by Rahul Guni on 7/17/21.
//

import UIKit
import Parse

class AddProductExtraViewController: UIViewController {
    @IBOutlet weak var headerLabel: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var contents: UITextView!
    
    private var myProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
        // Do any additional setup after loading the view.
        headerLabel.text = myProduct?.getTitle()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: myProduct!.getObjectId())
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // The query failed
                print(error.localizedDescription)
            } else if let object = object {
                
                if(self.discount.text != "") {
                    object["discount"] = Float(self.discount!.text!)
                }
                else{
                    object["discount"] = Float(0.0)
                }
                object["content"] = self.contents.text
                object.saveInBackground {(success, error) in
                    if(success) {
                        //go to main
                        self.performSegue(withIdentifier: "reloadEditShop", sender: self)
                        self.performSegue(withIdentifier: "reloadMyShop", sender: self)
                    }
                    else{
                        let alert = networkErrorAlert(title: "Error", errorString: "Failed to save.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                //Should not get down here because a product cannot be added without a product id which was created in the last view.
                // The query succeeded but no matching result was found
                
            }
        }
        
    }
    
    func setProduct(product: Product?) {
        self.myProduct = product
    }
    
}
