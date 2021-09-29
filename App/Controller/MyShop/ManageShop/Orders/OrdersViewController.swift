import UIKit
import Parse


/*Enum for Order Filter Buttons*/
enum orderFilter {
    case allOrders
    case pendingOrders
    case confirmedOrder
}

/**/
/*
class OrdersViewController

DESCRIPTION
        This class is a UIViewController that controls Orders.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        09/03/2021
 
*/
/**/

class OrdersViewController: UIViewController, shopManagerDelegate {
    
    //IBOutlet Elements
    @IBOutlet weak var ordersTable: UITableView!
    
    //Controller Parameters
    private var myShopId: String?                   //Current Shop's objectId
    private var myOrders: [Order] = []              //All Orders for current Shop
    private var currOrder: Order?                   //Current Order
    private var currOrderItems: [OrderItem] = []    //All items for current Order
    private var currProfile: User?                  //Current User who has placed the order
    private var currShop = ShopManager()            //ShopManager Delegate to perform segues to specified destinations.
    private var shippingAddress: Address?           //Shipping address for the order, if exists.
    
    private var currIndex: Int?                     //To record the selected order's index from myOrders Table
    private var forMyOrders: Bool = false           //To disable buttons if the next view is called from other places than ManageShop.
    private var filterType: orderFilter = orderFilter.allOrders //current Filter to view orders.
    
    //Declare a label to render in case there is no orders for selected filter.
    private let noOrdersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.ordersTable.delegate = self
        self.ordersTable.dataSource = self
        currShop.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterChange(_:)))
        checkOrderExists()
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
                self.checkOrderExists()
            }
        }
    }

}

//MARK:- IBOutlet Functions
extension OrdersViewController {
    //Action after Filter Button Click.
    @IBAction func filterChange(_ sender: UIButton) {
        self.showFilterAlert()
    }
}

//MARK:- Display Functions
extension OrdersViewController {
    
    //Setter function to set up current Shop objectId, passed on from previous view controller
    func setShopId(shopId: String) {
        self.myShopId = shopId
    }
    
    //Setter function to set up current Shop orders, passed on from previous view controller
    func setOrders(orders: [Order]) {
        self.myOrders = orders
    }
    
    //Delete function to delete order from table once completed, used from next view controller (MyOrderViewController)
    func deleteOrder() {
        self.myOrders.remove(at: self.currIndex!)
    }
    
    //Setter function to set up forMyOrders variable to render buttons accordingly, passed on from previous view controller
    func setMyOrders(bool: Bool) {
        self.forMyOrders = bool
    }
    
    //Function to perform segue
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    //Function to render noOrdersLabel if orders do not exist.
    private func checkOrderExists() {
        if(self.myOrders.isEmpty){
            self.ordersTable.isHidden = true
            self.view.backgroundColor = UIColor.lightGray
            noOrdersLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            noOrdersLabel.textAlignment = .center
            noOrdersLabel.text = "No Orderes Found."
            self.view.addSubview(noOrdersLabel)
        }
        else {
            self.view.backgroundColor = UIColor.white
            self.ordersTable.isHidden = false
            noOrdersLabel.removeFromSuperview()
        }
    }
    
    /**/
    /*
    private func getOrderItems()

    NAME

           getOrderItems - Get all items for current order

    DESCRIPTION

            This function fetches the objects in Order_Item table for current Order using the order's objectId.
            Then it appends the objects in currOrderItems array. Finally, it performs a segue to MyOrderViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getOrderItems() {
        self.currOrderItems.removeAll()
        let query = PFQuery(className: ShopIO.Order_Item().tableName)
        query.whereKey(ShopIO.Order_Item().orderId, equalTo: currOrder!.getObjectId())
        query.order(byDescending: ShopIO.Order_Item().createdAt)
        query.findObjectsInBackground {(orderItems, error) in
            if let orderItems = orderItems {
                for item in orderItems {
                    self.currOrderItems.append(OrderItem(orderItem: item))
                }
                self.performSegue(withIdentifier: "goToMyOrder", sender: self)
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getOrderItems() */
    
    /**/
    /*
    private func getProfile()

    NAME

           getProfile - Fetches data for current user who placed the order

    DESCRIPTION

            This function fetches the user's data in User table and record it in currProfile User object.
            Then it performs a segue to EditProfileViewController. If the order is to be shipped, it also
            fetches the data for Address using the addressId and records it in shippingAddress variable
            before performing segue.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getProfile(){
        let query = PFQuery(className: ShopIO.User().tableName)
        query.whereKey(ShopIO.User().objectId, equalTo: currOrder!.getUsertId())
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                self.currProfile = User(userID: user)
                //get Address if the order is to be delievered.
                if(self.currOrder!.getPickUp() == false) {
                    let addressQuery = PFQuery(className: ShopIO.Address().addressTableName)
                    addressQuery.whereKey(ShopIO.Address().objectId, equalTo: self.currOrder!.getAddressId())
                    addressQuery.getFirstObjectInBackground {(address, error) in
                        if let address = address {
                            self.shippingAddress = Address(address: address)
                            self.performSegue(withIdentifier: "goToProfile", sender: self)
                        }
                        else{
                            let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    self.performSegue(withIdentifier: "goToProfile", sender: self)
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getProfile() */
    
    /**/
    /*
    private func getShop()

    NAME

           getShop - Fetches data for current Shop where the order is placed.

    DESCRIPTION

            This function fetches the user's data in User table and record it in currProfile User object.
            Then it performs a segue to EditProfileViewController. If the order is to be shipped, it also
            fetches the data for Address using the addressId and records it in shippingAddress variable before
            performing segue.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getShop(){
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: self.currOrder!.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.currShop.setShop(shop: Shop(shop: shop))
                self.currShop.goToShop(shop: self.currShop.getCurrShop() ,identifier: "goToShop")
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getShop() */
    
    /**/
    /*
    private func showOrderAlert()

    NAME

           showOrderAlert - Shows alert options

    DESCRIPTION

            This function presents an alert in form format in order to choose what to do with the product.
            The options are:- Order Details, User Profile and Shop Profile. However, Shop Profile is available
            according to forMyOrders boolean variable.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func showOrderAlert() {
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
    /* private func showOrderAlert() */
    
    /**/
    /*
    private func showFilterAlert()

    NAME

           showFilterAlert - Shows alert options

    DESCRIPTION

            This function presents an alert in form format in order to filter the orders. The options are:-
            All Orders, Pending Orders and Completed Orders. Both deleted and confirmed orders are under
            Completed category.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func showFilterAlert() {
        let alert = UIAlertController(title: "Filter Order Details", message: "Choose what orders you want to view..", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All Orders", style: .default, handler: {(action: UIAlertAction) in
            self.getFilterOptions(filterOption: orderFilter.allOrders)
        }))
        alert.addAction(UIAlertAction(title: "Pending Orders", style: .default, handler: {(action: UIAlertAction) in
            self.getFilterOptions(filterOption: orderFilter.pendingOrders)
        }))
        alert.addAction(UIAlertAction(title: "Completed Orders", style: .default, handler: {(action: UIAlertAction) in
            self.getFilterOptions(filterOption: orderFilter.confirmedOrder)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /* private func showFilterAlert() */
    
    /**/
    /*
    private func getFilterOptions(filterOption: orderFilter)

    NAME

            getFilterOptions - Performs segue to MyOrderVoewController
     
     SYNOPSIS
            
            getFilterOptions(filterOption: orderFilter)
                 filterOption       --> orderFilter enum to pass to getOrder function to get filtered orders

    DESCRIPTION

            This function is the parent function to perform queries according to chosen filter.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getFilterOptions(filterOption: orderFilter) {
        let query = PFQuery(className: ShopIO.Order().tableName)
        
        if(self.forMyOrders) {
            query.whereKey(ShopIO.Order().userId, equalTo: currentUser!.objectId!)
        }
        else {
            query.whereKey(ShopIO.Order().shopId, equalTo: self.myShopId!)
        }
        
        if(filterOption == orderFilter.allOrders) {
            getOrders(query: query)
        }
        if(filterOption == orderFilter.confirmedOrder) {
            query.whereKey(ShopIO.Order().fulfilled, equalTo: true)
            getOrders(query: query)
        }
        if(filterOption == orderFilter.pendingOrders) {
            query.whereKey(ShopIO.Order().fulfilled, equalTo: false)
            getOrders(query: query)
        }
 
    }
    /* private func getFilterOptions(filterOption: orderFilter)*/
    
    /**/
    /*
     private func getOrders(query: PFQuery<PFObject>)

    NAME

            getOrder - Fetches Orders in Orders Table
     
     SYNOPSIS
            
            getOrders(query: PFQuery<PFObject>)
                 query       --> PFQuery Object passed from getFilterOptions to perform queries accordingly

    DESCRIPTION

            This function takes a query object, performs query in the Orders Table and appends the Order objects to myOrders array.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getOrders(query: PFQuery<PFObject>) {
        self.myOrders.removeAll()
        query.order(byDescending: ShopIO.ParseServer().updatedAt)
        query.findObjectsInBackground{(orders, error) in
            if let orders = orders {
                for order in orders {
                    let thisOrder = Order(order: order)
                    self.myOrders.append(thisOrder)
                }
                self.ordersTable.reloadData()
                self.checkOrderExists()
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getOrders(query: PFQuery<PFObject>) */
}

//MARK:- UITableViewDelegate
extension OrdersViewController: UITableViewDelegate {
    
    /**/
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

    NAME

           tableView - Action for TableView Cell click.

    DESCRIPTION

            This function records the current Order details and presents the order alerts from showAlertOptions and
            performs segue to MyOrderViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/19/2021

    */
    /**/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currIndex = indexPath.row
        self.currOrder = self.myOrders[self.currIndex!]
        self.shippingAddress = nil
        self.showOrderAlert()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) */
}

//MARK:- UITableViewDataSource
extension OrdersViewController: UITableViewDataSource {
    
    //function to render the number of Order Objects in TableView Cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.count
    }

    //function to populate the tableView Cells, from OrderTableViewCell.swift
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableOrdersCell", for: indexPath) as! OrdersTableViewCell
        cell.setParameters(order: self.myOrders[indexPath.row], forUser: self.forMyOrders)
        makePictureRounded(picture: cell.orderUserImage)
        return cell
    }
}
