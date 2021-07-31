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
    @IBOutlet weak var addMoreLabel: UILabel!
    
    //Get the product from shop view
    private var myProduct: Product?
    
    var productMode: forProducts?
    
    let realm = try! Realm()
    
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

        editAbleProduct(productMode!)
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyProductWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyStore") {
            let destination = segue.destination as! MyStoreViewController
            destination.replaceProduct(with: myProduct!)
        }
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forMyProduct
        }
    }
    
    func setMyProduct(product myProduct: Product) {
        self.myProduct = myProduct
    }
    
    
    func editAbleProduct(_ editMode: forProducts) {
        if(editMode == forProducts.forOwner) {
            setOwnerDisplay()
        }
        else if(editMode == forProducts.forMyShop) {
            self.addToCartButton.isHidden = true
        }
        else if (editMode == forProducts.forPublic){
            let cartObject = isInCart()
            if(cartObject != nil) {
                setCartDisplay(cartObject!)
            }
            else {
                setPublicDisplay()
            }
        }
        else if (editMode == forProducts.forCart) {
            let cartObject = isInCart()
            setCartDisplay(cartObject!)
        }
    }
    
    @IBAction func updateProduct(_ sender: Any) {
        if(productTitle.text!.isEmpty || priceField.text!.isEmpty || discountField.text!.isEmpty || quantityField.text!.isEmpty){
            let alert = networkErrorAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let query = PFQuery(className: "Product")
            query.getObjectInBackground(withId: myProduct!.getObjectId()) {(product: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                }
                else if let product = product {
                    product["title"] = self.productTitle.text!
                    product["summary"] = self.productDescription.text!
                    product["price"] = makeDouble(self.priceField.text!)
                    product["discount"] = (makeDouble(self.discountField.text!))
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
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if(currentUser != nil) {
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            
            //if object is already in cart, only update quantity
            let cartObject = isInCart()
            if(cartObject != nil){
                try! realm.write {
                    cartObject!.quantity = Int(quantityStepper.value)
                }
            }
            
            //else add the object to local storage
            else {
                let cartItem = CartItem()
                cartItem.userId = currentUser?.objectId
                cartItem.productId = myProduct?.getObjectId()
                cartItem.price = myProduct?.getPrice()
                cartItem.discount = myProduct?.getDiscountAmount()
                cartItem.productTitle = myProduct?.getTitle()
                cartItem.quantity = Int(quantityStepper.value)
                try! realm.write{
                    realm.add(cartItem)
                }
            }
            
            if(productMode == forProducts.forCart) {
                performSegue(withIdentifier: "goToMyCart", sender: self)
            }
            
            if(productMode == forProducts.forPublic) {
                performSegue(withIdentifier: "goToMyStore", sender: self)
            }
            
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    
    @IBAction func amountStepperChange(_ sender: UIStepper) {
        self.quantityField.text = (Int)(sender.value).description
    }
    
    //check if item is in cart and return cartobject
    private func isInCart() -> CartItem? {
        var myItem: CartItem?
        //search if this product already exists in cart
        let myCartItems = realm.objects(CartItem.self)
        for item in myCartItems {
            //return true if item already in cart
            if(item["productId"] as! String == myProduct!.getObjectId()) {
                if((item["userId"] as! String) == currentUser?.objectId) {
                    myItem = item
                }
            }
        }
        return myItem
    }
    
    private func setOwnerDisplay() {
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
    
    private func setCartDisplay(_ cartObject: CartItem) {
        self.addToCartButton.isHidden = false
        self.quantityStepper.isHidden = false
        self.quantityField.text = String(cartObject.quantity!)
        self.quantityStepper.value = Double(cartObject.quantity!)
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
    }
    
    private func setPublicDisplay(){
        self.quantityField.text = "1"
        self.quantityStepper.isHidden = false
        self.quantityStepper.value = 1.0
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
        self.addToCartButton.isHidden = false
    }

}
