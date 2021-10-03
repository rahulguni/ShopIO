import UIKit
import Parse
import RealmSwift

/**/
/*
class CheckOutViewController

DESCRIPTION
        This class is a UIViewController that controls Cart.storyboard's CheckOut view.
AUTHOR
        Rahul Guni
DATE
        08/23/2021
*/
/**/

class CheckOutViewController: UIViewController {
    
    //IBOutlet Elements
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var pickupButton: UIButton!
    @IBOutlet weak var shipButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    
    //Controller parameters
    private var myCart: Cart?                               //current Cart
    private var allCarts: [String: [CartItem]] = [:]        //List to separate cartItems according to shop
    private var myItems: [CartItem] = []                    //all items in cart
    private var deliveryAddressId: String?                  //objectId of address if delivery option is chosen
    private var pickUp: Bool?                               //determines if the order is for pickup or delivery
    private var fresh: Bool = false                         //to exit checkOut view if the view is exited before checking out.
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        modifyButtons(buttons: [pickupButton, shipButton, orderButton])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyAddresses") {
            let destination = segue.destination as! MyAddressViewController
            destination.setForOrder(bool: true)
        }
        if(segue.identifier! == "reloadMyCart") {
            let destination = segue.destination as! CartViewController
            destination.setOrderComplete(bool: self.fresh)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.makeCarts()
        if(self.fresh) {
            self.taxLabel.text = self.myCart!.getTaxAsString()
            self.totalLabel.text = self.myCart!.getSubTotalAsString()
        }
        else {
            self.performSegue(withIdentifier: "reloadMyCart", sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.fresh = false
    }
    
    @IBAction func unwindToCheckOutWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.pickUp = false
                self.shipButton.layer.borderWidth = 1.0
                self.shipButton.layer.borderColor = UIColor.black.cgColor
                self.pickupButton.layer.borderWidth = 0.0
                self.getShippingPrices()
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
    
    //setter function to set current cart, passed on from previous viewcontroller (CartViewController)
    func setCart(cart: Cart) {
        self.myCart = cart
    }
    
    //setter function to set current cart items, passed on from previous viewcontroller (CartViewController)
    func setItems(items: [CartItem]) {
        self.myItems = items
    }
    
    //setter function to set shipping address for the order, passed on from next viewcontroller (AddressViewController)
    func setAddressId(address: String) {
        self.deliveryAddressId = address
    }
    
    //setter function to set fresh boolean, only true if previous view controller is AddressViewController.
    func setFresh(bool: Bool) {
        self.fresh = bool
    }
    
    /**/
    /*
    private func uploadCart()

    NAME

           uploadCart - Uploads Cart to Cart Table

    DESCRIPTION

            This function loops through all the Order objects according to their shop and uploads individual orders to Orders table.
            After the order is completed, it also uploads all the cartItem objects to Order_Items table according to the order's objectId.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/23/2021

    */
    /**/
    
    private func uploadCart() {
        //make cart objects first
        for (shop, items) in self.allCarts {
            let query = PFQuery(className: ShopIO.Shop().tableName)
            query.whereKey(ShopIO.Shop().objectId, equalTo: shop)
            query.getFirstObjectInBackground{(shop, error) in
                if let shop = shop {
                    let shippingPrice = shop.value(forKey: ShopIO.Shop().shippingCost) as? Double
                    let myCart = Cart(cartItems: items)
                    let newCart = PFObject(className: ShopIO.Order().tableName)
                    newCart[ShopIO.Order().shopId] = shop.objectId!
                    newCart[ShopIO.Order().total] = myCart.getTotal()
                    newCart[ShopIO.Order().tax] = myCart.getTax()
                    newCart[ShopIO.Order().userId] = currentUser!.objectId!
                    if(!self.pickUp!) {
                        myCart.setShippingPrice(shipping: shippingPrice!)
                        newCart[ShopIO.Order().addressId] = self.deliveryAddressId!
                        newCart[ShopIO.Order().shipping] = myCart.getShippingPrice()
                    }
                    else{
                        newCart[ShopIO.Order().shipping] = 0.0
                    }
                    newCart[ShopIO.Order().itemDiscount] = myCart.getItemDiscount()
                    newCart[ShopIO.Order().pickUp] = self.pickUp!
                    newCart[ShopIO.Order().sessionId] = myCart.getSessionId()
                    newCart[ShopIO.Order().subTotal] = myCart.getSubTotal()
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
                else {
                    let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    /* private func uploadCart() */
    
    /**/
    /*
    private func uploadCartItems(items: [CartItem], cartId: String)

    NAME

            uploadCartItems - Uploads all items in cart
     
    SYNOPSIS
           
            uploadCartItems(items: [CartItem], cartId: String)
                items      --> items in cart
                cartId     --> objectId of cart after cart is uploaded

    DESCRIPTION

            This function takes in the cart items and objectId of a cart and inserts them in Order_Items table.
            At the same time, it also deletes the cartItem from Realm database as it is uploaded in server.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/23/2021

    */
    /**/
    
    private func uploadCartItems(items: [CartItem], cartId: String) {
        for item in items {
            let newItem = PFObject(className: ShopIO.Order_Item().tableName)
            newItem[ShopIO.Order_Item().discount] = item.discount
            newItem[ShopIO.Order_Item().orderId] = cartId
            newItem[ShopIO.Order_Item().price] = item.price
            newItem[ShopIO.Order_Item().productId] = item.productId
            newItem[ShopIO.Order_Item().quantity] = item.quantity
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
                    //save the current products in realm to a new database and upload it when internet connects.
                    print(error!.localizedDescription)
                }
            }
        }
    }
    /* private func uploadCartItems(items: [CartItem], cartId: String) */
    
    /**/
    /*
    private func getShippingPrices()

    NAME

            getShippingPrices - Fetches shipping price for each shop

    DESCRIPTION

            This function checks shipping price for each shop if pickUp is false. It then changes the UILabel fields
            according to total shipping cost.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/23/2021

    */
    /**/
    
    private func getShippingPrices(){
        var total = self.myCart!.getSubTotal()
        var shipTotal = 0.0
        for(shop, _) in self.allCarts {
            let query = PFQuery(className: ShopIO.Shop().tableName)
            query.whereKey(ShopIO.Shop().objectId, equalTo: shop)
            query.getFirstObjectInBackground{(currShop, error) in
                if let currShop = currShop {
                    total = ((total + (currShop.value(forKey: ShopIO.Shop().shippingCost) as! Double)) * 100).rounded() / 100
                    shipTotal = ((shipTotal + (currShop.value(forKey: ShopIO.Shop().shippingCost) as! Double)) * 100).rounded() / 100
                }
                else {
                    let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
                self.shippingLabel.text = "Shipping: $" + String(shipTotal)
                self.totalLabel.text = "SubTotal: $" + String(total)
            }
        }
    }
    /* private func getShippingPrices() */
}

//MARK:- IBOutlet Functions
extension CheckOutViewController {
    //Function to set shipping cost to $0 if pick up is selected.
    @IBAction func selectPickUp(_ sender: Any) {
        self.pickUp = true
        self.pickupButton.layer.borderWidth = 1.0
        self.pickupButton.layer.borderColor = UIColor.black.cgColor
        self.shipButton.layer.borderWidth = 0.0
        self.taxLabel.text = self.myCart!.getTaxAsString()
        self.totalLabel.text = self.myCart!.getSubTotalAsString()
        self.shippingLabel.text = "Shipping: $0"
    }
    
    //function to segue to MyAddressViewController to select shipping address
    @IBAction func selectShip(_ sender: Any) {
        self.performSegue(withIdentifier: "goToMyAddresses", sender: self)
    }
    
    //Action for Order Button Click, upload current cart in Order Table.
    @IBAction func orderButtonPressed(_ sender: Any) {
        if(self.pickUp == nil) {
            let alert = customNetworkAlert(title: "Missing Delivery Option", errorString: "Please select pickup or delivery for your order.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Confirm Order?", message: "Please select below", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm Button"), style: .default, handler: { _ in
                self.uploadCart()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
