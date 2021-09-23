//
//  MyOrderViewController.swift
//  App
//
//  Created by Rahul Guni on 9/3/21.
//

import UIKit
import Parse

class MyOrderViewController: UIViewController {
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var confirmOrderButton: UIButton!
    @IBOutlet weak var deleteOrderButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    
    private var currOrder: Order?
    private var orderItems: [OrderItem] = []
    private var currOrderItem: OrderItem?
    private var currProductItem: Product?
    private var currProductImage: [ProductImage] = []
    
    private var forMyOrders: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        orderTable.delegate = self
        orderTable.dataSource = self
        if(forMyOrders || self.currOrder!.getFulfilled()) {
            confirmOrderButton.isHidden = true
            deleteOrderButton.isHidden = true
        }
        else {
            modifyButtons(buttons: [confirmOrderButton, deleteOrderButton])
        }
        setLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: currProductItem!)
            destination.setImages(myImages: currProductImage)
            if(self.forMyOrders) {
                destination.productMode = ProductMode.forPublic
            }
            else {
                destination.productMode = ProductMode.forMyShop
            }
            
        }
        
        if(segue.identifier! == "reloadOrder") {
            let destination = segue.destination as! OrdersViewController
            destination.deleteOrder()
        }
    }
}

//MARK:- IBOutlet Functions
extension MyOrderViewController {
    @IBAction func confirmButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Order?", message: "Please select below", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .default, handler: { _ in
            self.confirmOrder(delete: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete order?", message: "Please select below", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .default, handler: { _ in
            self.confirmOrder(delete: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- Display Functions
extension MyOrderViewController {
    
    func setCurrOrder(order: Order) {
        self.currOrder = order
    }
    
    func setOrderItems(items: [OrderItem]) {
        self.orderItems = items
    }
    
    func setMyOrders(bool: Bool) {
        self.forMyOrders = bool
    }
    
    private func setLabels(){
        self.totalLabel.text = "Total: " + String(currOrder!.getTotal())
        self.discountLabel.text = "Discount: " + String(currOrder!.getItemDiscount())
        self.taxLabel.text = "Tax: " + String(currOrder!.getTax())
        let shippingCost = ((currOrder!.getSubTotal() - currOrder!.getTotal() - currOrder!.getTax())*100).rounded() / 100
        if(shippingCost > 0) {
            self.subTotalLabel.text = "Subtotal (inc. $\(shippingCost) shipping): " + String(currOrder!.getSubTotal())
        }
        else {
            self.subTotalLabel.text = "Subtotal: " + String(currOrder!.getSubTotal())
        }
    }
    
    private func goToMyProduct() {
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: currOrderItem!.getProductId())
        query.getFirstObjectInBackground{ (object: PFObject?, error: Error?) in
            if let error = error {
                let alert = customNetworkAlert(title: "Could not load item.", errorString: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            } else if let object = object {
                self.currProductItem = Product(product: object)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: "Product_Images")
                query.whereKey("productId", equalTo: self.currProductItem!.getObjectId())
                query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
                    if let error = error {
                        // Log details of the failure
                        let alert = customNetworkAlert(title: "Unable to connect", errorString: error.localizedDescription)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if let objects = objects {
                        for object in objects {
                            let productImage = ProductImage(image: object)
                            self.currProductImage.append(productImage)
                        }
                        self.performSegue(withIdentifier: "goToMyProduct", sender: self)
                    }
                }
            }
        }
    }
    
    private func confirmOrder(delete: Bool){
        let query = PFQuery(className: "Order")
        query.whereKey("objectId", equalTo: currOrder!.getObjectId())
        query.getFirstObjectInBackground{(order, error) in
            if let order = order {
                order["fulfilled"] = true
                order.saveInBackground{(success, error) in
                    if(success) {
                        if(delete) {
                            self.deleteOrderItems()
                            self.sendMessage(delete: delete)
                        }
                        else{
                            self.modifyProductQuantity()
                            self.sendMessage(delete: delete)
                        }
                        self.performSegue(withIdentifier: "reloadOrder", sender: self)
                        
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to order", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func modifyProductQuantity(){
        for item in self.orderItems {
            let query = PFQuery(className: "Product")
            query.whereKey("objectId", equalTo: item.getProductId())
            query.getFirstObjectInBackground{(product, error) in
                if let product = product {
                    product["quantity"] = Product(product: product).getQuantity() - item.getQuantity()
                    product.saveInBackground()
                }
                else {
                    let alert = customNetworkAlert(title: "Unable to modify product quantity", errorString: "There was an error connecting to the server. Please check your internet connection and update your product quantity from your inventory..")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func deleteOrderItems(){
        for item in self.orderItems {
            let query = PFQuery(className: "Order_Item")
            query.whereKey("objectId", equalTo: item.getObjectId())
            query.getFirstObjectInBackground{(orderItem, error) in
                if let orderItem = orderItem{
                    orderItem.deleteEventually()
                }
            }
        }
    }
    
    private func sendMessage(delete: Bool){
        let query = PFQuery(className: "Messages")
        query.whereKey("receiverId", equalTo: currOrder!.getShopId())
        query.whereKey("senderId", equalTo: currOrder!.getUsertId())
        query.getFirstObjectInBackground{(message, error) in
            if let message = message {
                //chatRoom already exists, add to chat.
                message["updatedAt"] = Date()
                message.saveInBackground()
                self.saveChat(message: message, delete: delete)
            }
            //if not exists, create one and send message.
            else {
                let message = PFObject(className: "Messages")
                message["senderId"] = self.currOrder!.getUsertId()
                message["receiverId"] = self.currOrder!.getShopId()
                
                message.saveInBackground{(success, error) in
                    if(success) {
                        self.saveChat(message: message, delete: delete)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Error sending message to buyer.", errorString: "There was an error connecting to the server. The order has been marked confirmed. Please notify the co=ustomer manually.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func saveChat(message: PFObject, delete: Bool) {
        let chatRoom = PFObject(className: "ChatRoom")
        chatRoom["chatRoomId"] = message.objectId!
        chatRoom["senderId"] = self.currOrder!.getShopId()
        if(!delete) {
            chatRoom["message"] = "Your order has been confirmed. Thank you for choosing us."
        }
        else {
            chatRoom["message"] = "We cannot process your order at this time. Apologies!."
        }
        chatRoom.saveInBackground()
    }
}

//MARK:- UITableViewDelegate
extension MyOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currOrderItem = self.orderItems[indexPath.row]
        goToMyProduct()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension MyOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resuableOrderItemCell", for: indexPath) as! MyOrderTableViewCell
        cell.setParameters(orderItem: self.orderItems[indexPath.row])
        return cell
    }
    
    
}
