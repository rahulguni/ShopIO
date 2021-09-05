//
//  EditShopViewController.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//

import UIKit
import Parse

class ManageShopViewController: UIViewController {
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var updateInventory: UIButton!
    @IBOutlet weak var orders: UIButton!
    
    private var currShop: Shop?
    private var myOrders: [Order] = []
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToEditShopWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toAddProduct") {
            let destination = segue.destination as! AddProductViewController
            destination.setShop(shop: currShop)
        }
        
        if(segue.identifier! == "goToOrders") {
            let destination = segue.destination as! OrdersViewController
            destination.setShopId(shopId: self.currShop!.getShopId())
            destination.setOrders(orders: self.myOrders)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentButtons: [UIButton] = [addProduct, updateInventory, orders]
        modifyButtons(buttons: currentButtons)
    }
    
    
    @IBAction func ordersButtonPressed(_ sender: Any) {
        self.getOrders()
    }
    
}

//MARK:- Display Functions
extension ManageShopViewController {
    
    func setShop(shop: Shop?) {
        self.currShop = shop
    }
    
    func getOrders(){
        self.myOrders.removeAll()
        let query = PFQuery(className: "Order")
        query.whereKey("shopId", equalTo: self.currShop!.getShopId())
        query.whereKey("fulfilled", equalTo: false)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {(orders, error) in
            if let orders = orders {
                for order in orders {
                    self.myOrders.append(Order(order: order))
                }
                self.performSegue(withIdentifier: "goToOrders", sender: self)
            }
        }
    }
}
