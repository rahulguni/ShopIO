import UIKit
import Parse

/**/
/*
class MyOrderViewController

DESCRIPTION
        This class is a UIViewController that controls Order.storyboard's MyOrder View.
 
AUTHOR
        Rahul Guni
 
DATE
        09/03/2021
 
*/
/**/

class MyOrderViewController: UIViewController {
    
    //IBOutlet Elements
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var confirmOrderButton: UIButton!
    @IBOutlet weak var deleteOrderButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    
    private var currOrder: Order?                       //current Order object
    private var orderItems: [OrderItem] = []            //OrderItem objects array for current product
    private var currOrderItem: OrderItem?               //OrderItem object for current Order Item
    private var currProductItem: Product?               //Product object queried from currOrderItem's productId
    private var currProductImage: [ProductImage] = []   //Images for currentProduct
    
    private var forMyOrders: Bool = false               //Determines whether or not to render order option buttons.
    
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
    
    /**/
    /*
    @IBAction func confirmButtonClicked(_ sender: Any)

    NAME

           confirmButtonClicked - Action for Confirm Order click.

    DESCRIPTION

            This function presents an alert to confirm the order. The button is only available if the Order view
            is segued from ManageShopViewController. The users can only view the order.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
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
    /* @IBAction func confirmButtonClicked(_ sender: Any)*/
    
    /**/
    /*
    @IBAction func deleteButtonClicked(_ sender: Any)

    NAME

           deleteButtonClicked - Action for Delete Order click.

    DESCRIPTION

            This function presents an alert to delete the order. The button is only available if the Order view is
            segued from ManageShopViewController. The users can only view the order.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
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
    /* @IBAction func deleteButtonClicked(_ sender: Any) */
}

//MARK:- Display Functions
extension MyOrderViewController {
    
    //Setter function to set up current Order, passed on from previous view controller (OrderViewController)
    func setCurrOrder(order: Order) {
        self.currOrder = order
    }
    
    //Setter function to set up current Order's Order Items, passed on from previous view controller (OrderViewController)
    func setOrderItems(items: [OrderItem]) {
        self.orderItems = items
    }
    
    //Setter function to set up forMyOrders variable, passed on from previous view controller (OrderViewController)
    func setMyOrders(bool: Bool) {
        self.forMyOrders = bool
    }
    
    /**/
    /*
    private func setLabels()

    NAME

           setLabels - Sets Labels for the view

    DESCRIPTION

            This function sets up the labels in current view according to the order details obtained from currOrder Order object.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
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
    /* private func setLabels() */
    
    /**/
    /*
    private func goToMyProduct()

    NAME

           goToMyProduct - Performs segue to MyProductViewController

    DESCRIPTION

            This function queries the Product table from the productId of current Order Item. Once the product is found,
            it searches the Product_Images table to render the product's image and segues to MyProductViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
    private func goToMyProduct() {
        //Query the product first
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().objectId, equalTo: currOrderItem!.getProductId())
        query.getFirstObjectInBackground{ (object: PFObject?, error: Error?) in
            if let error = error {
                let alert = customNetworkAlert(title: "Could not load item.", errorString: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }
            else if let object = object {
                self.currProductItem = Product(product: object)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: ShopIO.Product_Images().tableName)
                query.whereKey(ShopIO.Product_Images().productId, equalTo: self.currProductItem!.getObjectId())
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
                            self.performSegue(withIdentifier: "goToMyProduct", sender: self)
                        }
                    }
                }
            }
        }
    }
    /* private func goToMyProduct() */
    
    /**/
    /*
    private func confirmOrder(delete: Bool)

    NAME

           confirmOrder - Fulfills the order in Order table
     
    SYNOPSIS
            confirmOrder(delete: Bool)
                delete      --> A boolean variable to determine whether to confirm the order or delete it.

    DESCRIPTION

            This function takes in a boolean variable to decide what to do with the order. If false, the order items in
            Order_Items tables get deleted. In both cases, the order is marked fulfilled and a message is sent to the
            user who placed an order regarding the status of the order.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
    private func confirmOrder(delete: Bool){
        let query = PFQuery(className: ShopIO.Order().tableName)
        query.whereKey(ShopIO.Order().objectId, equalTo: currOrder!.getObjectId())
        query.getFirstObjectInBackground{(order, error) in
            if let order = order {
                order[ShopIO.Order().fulfilled] = true
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
                        let alert = customNetworkAlert(title: "Unable to confirm order", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    /* private func confirmOrder(delete: Bool) */
    
    /**/
    /*
    private func modifyProductQuantity()

    NAME

           modifyProductQuantity - Modifies the confirmed Order Item Quantity

    DESCRIPTION

            This function queries the Product table from the productId of current Order Item in orderItems array.
            Once the product is found, it modifies the product quantity by subtracting current quantity with ordered Items.
            If in any case the query fails, it alerts the user to update the product manually in their inventory.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
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
                    let alert = customNetworkAlert(title: "Unable to modify product quantity", errorString: "There was an error connecting to the server. Please check your internet connection and update your product quantity from your inventory.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    /* private func modifyProductQuantity() */
    
    /**/
    /*
    private func deleteOrderItems()

    NAME

           deleteOrderItems - Delete Order Items

    DESCRIPTION

            This function queries the Order_Item table and deletes the items for current Order.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
    private func deleteOrderItems(){
        for item in self.orderItems {
            let query = PFQuery(className: ShopIO.Order_Item().tableName)
            query.whereKey(ShopIO.Order_Item().objectId, equalTo: item.getObjectId())
            query.getFirstObjectInBackground{(orderItem, error) in
                if let orderItem = orderItem{
                    orderItem.deleteEventually()
                }
            }
        }
    }
    /* private func deleteOrderItems() */
    
    /**/
    /*
    private func sendMessage(delete: Bool)

    NAME

            sendMessage - Creates/Updates Message after order completion.
     
    SYNOPSIS
     
            sendMessage(delete: Bool)
                delete      -->  Boolean variable to send message stating whether the Order has been confirmed or deleted

    DESCRIPTION

            This function takes in a boolean variable that states the completion status of order. If a chatroom already exists
            between the two parties, it simply updates the updatedAt time in Message Table. Otherwise, it creates a new entry in
            the table and sends message. In other words, a new Message object is created and uploaded.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
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
    /* private func sendMessage(delete: Bool) */
    
    /**/
    /*
    private func saveChat(message: PFObject, delete: Bool)

    NAME

            saveChat - Sends Chat to user after order completion.
     
    SYNOPSIS
     
            saveChat(message: PFObject, delete: Bool)
                message     --> A PFObject whose objectId corresponds to the current chatRoomId.
                delete      -->  Boolean variable to send message stating whether the Order has been confirmed or deleted

    DESCRIPTION

            This function queries the ChatRoom table using the PFObject's objectId which is also the chatRoomId for two parties.
            A message is sent to user according to order completion status.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            9/03/2021

    */
    /**/
    
    private func saveChat(message: PFObject, delete: Bool) {
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
    /* private func saveChat(message: PFObject, delete: Bool) */
}

//MARK:- UITableViewDelegate
extension MyOrderViewController: UITableViewDelegate {
    
    //Go to MyProductViewController if a tableview cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currOrderItem = self.orderItems[indexPath.row]
        goToMyProduct()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension MyOrderViewController: UITableViewDataSource {
    
    //function to render the number of Order Item Objects in TableView Cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderItems.count
    }
    
    //function to populate the tableView Cells, from MyOrderTableViewCell.swift
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resuableOrderItemCell", for: indexPath) as! MyOrderTableViewCell
        cell.setParameters(orderItem: self.orderItems[indexPath.row])
        return cell
    }
    
    
}
