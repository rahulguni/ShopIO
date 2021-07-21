//
//  AddProductViewController.swift
//  App
//
//  Created by Rahul Guni on 7/17/21.
//

import UIKit
import Parse

class AddProductViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var summaryField: UITextView!
    @IBOutlet weak var imageField: UIImageView!
    
    private var myShop: Shop?
    private var myProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true

        // Do any additional setup after loading the view.
        summaryField.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        summaryField.layer.borderWidth = 1.0
        summaryField.layer.cornerRadius = 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddProductExtraViewController
        destination.setProduct(product: myProduct)
    }
    
    
    @IBAction func saveProduct(_ sender: Any) {
        let currProduct = PFObject(className: "Product")
        currProduct["userId"] = currentUser?.objectId
        currProduct["title"] = titleField.text!
        currProduct["price"] = Double(priceField.text!)
        currProduct["quantity"] = Int(quantityField.text!)
        currProduct["summary"] = summaryField.text!
        currProduct["shopId"] = myShop?.getShopId()
        
        myProduct = Product(product: currProduct)
        
        currProduct.saveInBackground{(success, error) in
            if(success) {
                self.myProduct?.setObjectId(product: currProduct)
                self.performSegue(withIdentifier: "goToAddProductsExtra", sender: self)
            }
            else{
                print("failed")
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        //segue to main
        self.dismiss(animated: true, completion: nil)
    }
    
    func setShop(shop: Shop?) {
        self.myShop = shop
    }
    
    func setProduct(product: Product?) {
        self.myProduct = product
    }
    
}
