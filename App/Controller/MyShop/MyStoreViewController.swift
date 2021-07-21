//
//  MyStoreView.swift
//  App
//
//  Created by Rahul Guni on 7/1/21.
//

import UIKit
import Parse

class MyStoreViewController: UIViewController {

    @IBOutlet weak var shopSlogan: UITextField!
    @IBOutlet weak var shopTitle: UITextField!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var noProductText: UITextField!
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var productsField: UITextView!
    
    //Build a shop model
    private var currShop : Shop?
    
    //a dictionary to store all products of the shop
    private var myProducts: [String: Product]?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toAddProduct") {
            let destination = segue.destination as! AddProductViewController
            destination.setShop(shop: currShop)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyStoreWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.hasProduct(true)
                self.viewDidLoad()
                self.viewDidAppear(true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButton(button: addProduct)
        shopSlogan.text = currShop?.getShopSlogan()
        shopTitle.text = currShop?.getShopTitle()
        fillMyProducts()
    }

    func fillMyProducts() {
        //find all products from the store and put it in the dictionary
        let query = PFQuery(className: "Product")
        query.whereKey("shopId", equalTo: currShop!.getShopId())
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let error = error {
                //Request failed
                print(error.localizedDescription)
            }
            else if let products = products {
                //products found in parse cloud database
                if(products.count == 0) {
                    self.hasProduct(false)
                }
                else {
                    for currProduct in products {
                        let tempProduct = Product(product: currProduct)
                        self.myProducts?[tempProduct.getTitle()] = tempProduct
                        self.productsField.text! += tempProduct.getTitle() + " Quantity: " + tempProduct.getQuantity() + " Price: " + String(tempProduct.getPrice()) + "\n"
                    }
                }
            }
        }
    }
    
    func setShop(shop: Shop?){
        self.currShop = shop
    }
    
    func hasProduct(_ bool: Bool) {
        self.addProduct.isHidden = bool
        self.noProductText.isHidden = bool
        self.productsField.isHidden = !bool
    }

}
