//
//  OrdersViewController.swift
//  App
//
//  Created by Rahul Guni on 9/3/21.
//

import UIKit
import Parse

class OrdersViewController: UIViewController, shopManagerDelegate {
    
    @IBOutlet weak var ordersTable: UITableView!
    
    private var myShopId: String?
    private var myOrders: [Order] = []
    private var currOrder: Order?
    private var currOrderItems: [OrderItem] = []
    private var currProfile: User?
    private var currShop = ShopManager()
    private var shippingAddress: Address?
    
    private var currIndex: Int?
    private var forMyOrders: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ordersTable.delegate = self
        self.ordersTable.dataSource = self
        currShop.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyOrder") {
            let destination = segue.destination as! MyOrderViewController
            destination.setCurrOrder(order: self.currOrder!)
            destination.setOrderItems(items: self.currOrderItems)
            destination.setMyOrders(bool: self.forMyOrders)
        }
        if(segue.identifier! == "goToProfile") {
            let destination = segue.destination as! EditProfileViewController
            destination.setForOrder(bool: true)
            destination.setUser(currUser: currProfile!)
            if let address = shippingAddress {
                destination.setDeliveryAddress(address: address)
            }
        }
        if(segue.identifier! == "goToShop") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: currShop.getCurrShop())
            destination.fillMyProducts(productsList: currShop.getCurrProducts())
            destination.setForShop(ProductMode.forPublic)
        }
    }
    
    //Function to unwind the segue and reload table cells
    @IBAction func unwindToOrderWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.ordersTable.reloadData()
            }
        }
    }

}

//MARK:- Display Functions
extension OrdersViewController {
    func setShopId(shopId: String) {
        self.myShopId = shopId
    }
    
    func setOrders(orders: [Order]) {
        self.myOrders = orders
    }
    
    func deleteOrder() {
        self.myOrders.remove(at: self.currIndex!)
    }
    
    func setMyOrders(bool: Bool) {
        self.forMyOrders = bool
    }
    
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    private func getOrderItems() {
        self.currOrderItems.removeAll()
        let query = PFQuery(className: "Order_Item")
        query.whereKey("orderId", equalTo: currOrder!.getObjectId())
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {(orderItems, error) in
            if let orderItems = orderItems {
                for item in orderItems {
                    self.currOrderItems.append(OrderItem(orderItem: item))
                }
                self.performSegue(withIdentifier: "goToMyOrder", sender: self)
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    private func getProfile(){
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: currOrder!.getUsertId())
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                self.currProfile = User(userID: user)
                if(self.currOrder!.getPickUp() == false) {
                    let addressQuery = PFQuery(className: "Address")
                    addressQuery.whereKey("objectId", equalTo: self.currOrder!.getAddressId())
                    addressQuery.getFirstObjectInBackground {(address, error) in
                        if let address = address {
                            self.shippingAddress = Address(address: address)
                        }
                        else{
                            print(error.debugDescription)
                        }
                        self.performSegue(withIdentifier: "goToProfile", sender: self)
                    }
                }
                else {
                    self.performSegue(withIdentifier: "goToProfile", sender: self)
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    private func getShop(){
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: self.currOrder!.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.currShop.setShop(shop: Shop(shop: shop))
                self.currShop.goToShop(shop: self.currShop.getCurrShop() ,identifier: "goToShop")
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Order Item Details", message: "Choose what you want to do with this order.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Show Order Details", style: .default, handler: {(action: UIAlertAction) in
            self.getOrderItems()
        }))
        alert.addAction(UIAlertAction(title: "Show Profile", style: .default, handler: {(action: UIAlertAction) in
            self.getProfile()
        }))
        if(self.forMyOrders) {
            alert.addAction(UIAlertAction(title: "Show Shop", style: .default, handler: {(action: UIAlertAction) in
                self.getShop()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- UITableViewDelegate
extension OrdersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currIndex = indexPath.row
        self.currOrder = self.myOrders[self.currIndex!]
        self.shippingAddress = nil
        self.showAlert()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension OrdersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableOrdersCell", for: indexPath) as! OrdersTableViewCell
        cell.setParameters(order: self.myOrders[indexPath.row], forUser: self.forMyOrders)
        makePictureRounded(picture: cell.orderUserImage)
        return cell
    }
}
