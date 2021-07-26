//
//  MyProductViewController.swift
//  App
//
//  Created by Rahul Guni on 7/21/21.
//

import UIKit
import Parse
import RealmSwift

class MyProductViewController: UIViewController {
    @IBOutlet weak var productTitle: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productContent: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var discountField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var discountPerLabel: UILabel!
    
    //Get the product from shop view
    private var myProduct: Product?
    
    private var editMode: Bool = false
    
    private var ownerMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Fix Buttons
        let currentButtons: [UIButton] = [updateButton, addToCartButton]
        modifyButtons(buttons: currentButtons)
        
        self.productTitle.text = myProduct!.getTitle()
        self.priceField.text = myProduct!.getPriceAsString()
        self.quantityField.text = String(myProduct!.getQuantity())
        self.productDescription.text = myProduct!.getSummary()
        self.quantityStepper.value = Double(myProduct!.getQuantity())
        
        if(myProduct?.getDiscount() != 0) {
            discountField.isHidden = false
            let attributeString = makeStrikethroughText(product: myProduct!)
            self.discountField.attributedText = attributeString
        }
    
        editAbleProduct(editMode, ownerMode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyStore") {
            let destination = segue.destination as! MyStoreViewController
            destination.replaceProduct(with: myProduct!)
        }
    }
    
    func setMyProduct(product myProduct: Product) {
        self.myProduct = myProduct
    }
    
    func setEditMode(_ bool: Bool,_ bool1: Bool) {
        self.editMode = bool
        self.ownerMode = bool1
    }
    
    func editAbleProduct(_ editMode: Bool,_ shopMode: Bool) {
        if(editMode) {
            self.productTitle.isUserInteractionEnabled = true
            self.productDescription.isUserInteractionEnabled = true
            self.productContent.isUserInteractionEnabled = true
            self.discountField.isUserInteractionEnabled = true
            self.priceField.isUserInteractionEnabled = true
            self.priceField.text = self.myProduct!.getOriginalPrice()
            self.quantityField.isUserInteractionEnabled = true
            self.discountField.borderStyle = UITextField.BorderStyle.roundedRect
            self.priceField.borderStyle = UITextField.BorderStyle.roundedRect
            self.quantityField.borderStyle = UITextField.BorderStyle.roundedRect
            self.quantityStepper.isHidden = false
            self.discountField.text = nil
            self.discountField.isHidden = false
            self.discountField.placeholder = "Discount"
            self.updateButton.isHidden = false
            self.discountPerLabel.isHidden = false
        }
        if(shopMode) {
            self.addToCartButton.isHidden = true
        }
    }
    
    @IBAction func updateProduct(_ sender: Any) {
        let query = PFQuery(className: "Product")
        query.getObjectInBackground(withId: myProduct!.getObjectId()) {(product: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let product = product {
                product["title"] = self.productTitle.text!
                product["summary"] = self.productDescription.text!
                product["price"] = self.makeDouble(self.priceField.text!)
                product["discount"] = self.makeDouble(self.discountField.text!)
                product["quantity"] = Int(self.quantityField.text!)
                product.saveInBackground{(success, error) in
                    if(success) {
                        let tempProd = Product(product: product)
                        self.myProduct = tempProd
                        self.performSegue(withIdentifier: "goToMyStore", sender: self)
                    }
                    else {
                        let alert = networkErrorAlert(title: "Could not save object", errorString: "Connection error. Please try again later.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }

            }
        }
        
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if(currentUser != nil) {
            var forUpdate: Bool = false
            
            let realm = try! Realm()
            let cartItem = CartItem()
            cartItem.userId = currentUser?.objectId
            cartItem.productId = myProduct?.getObjectId()
            cartItem.price = myProduct?.getPrice()
            cartItem.discount = myProduct?.getDiscountAmount()
            
            //search if same item already exists in cart
            let myCartItems = realm.objects(CartItem.self)
            
            for item in myCartItems {
                //if exists in cart for current user, only update the quantity
                if(item["productId"] as! String == myProduct!.getObjectId()) {
                    if((item["userId"] as! String) == currentUser!.objectId) {
                        let quantity = item["quantity"] as! Int
                        forUpdate = true
                        try! realm.write{
                            item.quantity = quantity + 1
                        }
                    }
                }
            }
            
            if(!forUpdate) {
                cartItem.quantity = 1
                try! realm.write{
                    realm.add(cartItem)
                }
            }
        }
        else {
            let alert = networkErrorAlert(title: "Cannot add to cart", errorString: "Please sign in to continue.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func amountStepperChange(_ sender: UIStepper) {
        self.quantityField.text = (Int)(sender.value).description
    }
    
    private func makeDouble(_ textField: String) -> Double? {
        var temp = textField
        if(textField.first == "$") {
            temp = String(textField.dropFirst())
        }
        return Double(temp)
    }

}
