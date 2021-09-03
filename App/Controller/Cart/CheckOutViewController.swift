//
//  CheckOutViewController.swift
//  App
//
//  Created by Rahul Guni on 8/23/21.
//

import UIKit
import Parse
import RealmSwift

class CheckOutViewController: UIViewController {
    
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var pickupButton: UIButton!
    @IBOutlet weak var shipButton: UIButton!
    
    private var myCart: Cart?
    private var allCarts: [String: [CartItem]] = [:]
    private var myItems: [CartItem] = []
    private var deliveryAddressId: String?
    private var pickUp: Bool?
    private let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.taxLabel.text = self.myCart!.getTaxAsString()
        self.totalLabel.text = self.myCart!.getSubTotalAsString()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyAddresses") {
            let destination = segue.destination as! MyAddressViewController
            destination.setForOrder(bool: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.getAddresses()
        self.makeCarts()
    }
    
    @IBAction func unwindToCheckOutWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.pickUp = false
                self.shipButton.layer.borderWidth = 1.0
                self.shipButton.layer.borderColor = UIColor.black.cgColor
                self.pickupButton.layer.borderWidth = 0.0
            }
        }
    }
}

//MARK:- Regular Functions
extension CheckOutViewController {
    //separate orders according to shopIds
    private func makeCarts() {
        for item in self.myItems {
            if(allCarts[item.productShop!] != nil) {
                allCarts[item.productShop!]!.append(item)
            }
            else {
                allCarts[item.productShop!] = [item]
            }
        }
    }
    
    func setCart(cart: Cart) {
        self.myCart = cart
    }
    
    func setItems(items: [CartItem]) {
        self.myItems = items
    }
    
    func setAddressId(address: String) {
        self.deliveryAddressId = address
    }
    
    func uploadCart() {
        //make cart objects first
        for (shop, items) in self.allCarts {
            let myCart = Cart(cartItems: items)
            let newCart = PFObject(className: "Order")
            newCart["shopId"] = shop
            newCart["total"] = myCart.getTotal()
            newCart["subTotal"] = myCart.getSubTotal()
            newCart["tax"] = myCart.getTax()
            newCart["userId"] = currentUser!.objectId!
            if(!pickUp!) {
                newCart["addressId"] = self.deliveryAddressId!
            }
            newCart["itemDiscount"] = myCart.getItemDiscount()
            newCart["pickUp"] = self.pickUp!
            newCart["sessionId"] = myCart.getSessionId()
            newCart.saveInBackground{(success, error) in
                if(success) {
                    //upload order products
                    self.uploadCartItems(items:items, cartId: newCart.objectId!)
                }
                else {
                    let alert = customNetworkAlert(title: "Error ordering", errorString: "There was an error ordering your item. Please try again.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func uploadCartItems(items: [CartItem], cartId: String) {
        for item in items {
            let newItem = PFObject(className: "Order_Item")
            newItem["discount"] = item.discount
            newItem["orderId"] = cartId
            newItem["price"] = item.price
            newItem["productId"] = item.productId
            newItem["quantity"] = item.quantity
            newItem.saveInBackground {(success, error) in
                if(success) {
                    //clear all cartItems from local database
                    do {
                        try self.realm.write{
                            self.realm.delete(item)
                        }
                    }catch {
                        print("error deleting cart items.")
                    }
                    let cartObjects = self.realm.objects(CartItem.self)
                    //segue to empty cart when all objects are removed from local database
                    if(cartObjects.filter("userId == '\(currentUser!.objectId!)'").count == 0){
                        self.performSegue(withIdentifier: "reloadMyCart", sender: self)
                    }
                }
                else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
}

//MARK:- IBOutlet Functions
extension CheckOutViewController {
    @IBAction func selectPickUp(_ sender: Any) {
        self.pickUp = true
        self.pickupButton.layer.borderWidth = 1.0
        self.pickupButton.layer.borderColor = UIColor.black.cgColor
        self.shipButton.layer.borderWidth = 0.0
    }
    
    @IBAction func selectShip(_ sender: Any) {
        self.performSegue(withIdentifier: "goToMyAddresses", sender: self)
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        if(self.pickUp == nil) {
            let alert = customNetworkAlert(title: "Missing Delivery Option", errorString: "Please select pickup or delivery for your order.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            uploadCart()
        }
    }
}
