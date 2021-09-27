import UIKit
import Parse

/**/
/*
class ManageShopViewController

DESCRIPTION
        This class is a UIViewController that controls ManageShop.storyboard View.
 
AUTHOR
        Rahul Guni
 
DATE
        07/15/2021
 
*/
/**/

class ManageShopViewController: UIViewController {
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var updateInventory: UIButton!
    @IBOutlet weak var orders: UIButton!
    
    private var currShop: Shop?             //current Shop Object
    private var myOrders: [Order] = []      //orders for current Shop
    
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
    
    //Action for Orders Button Click
    @IBAction func ordersButtonPressed(_ sender: Any) {
        self.getOrders()
    }
    
}

//MARK:- Display Functions
extension ManageShopViewController {
    
    //Setter function to set up current Shop, passed on from previous view controller (MyShopViewController)
    func setShop(shop: Shop?) {
        self.currShop = shop
    }
    
    /**/
    /*
    private func getOrders()

    NAME

           getOrders - Fetches orders for current Shop.

    DESCRIPTION

            This function queries the Order table for current Shop using currShop's objectId/shopId, and appends
            the order items to myOrders array. Finally, it performs segue to OrdersViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/15/2021

    */
    /**/
    
    private func getOrders(){
        self.myOrders.removeAll()
        let query = PFQuery(className: ShopIO.Order().tableName)
        query.whereKey(ShopIO.Order().shopId, equalTo: self.currShop!.getShopId())
        query.whereKey(ShopIO.Order().fulfilled, equalTo: false)
        query.order(byDescending: ShopIO.Order().createdAt)
        query.findObjectsInBackground {(orders, error) in
            if let orders = orders {
                for order in orders {
                    self.myOrders.append(Order(order: order))
                }
                self.performSegue(withIdentifier: "goToOrders", sender: self)
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getOrder()*/
}
