import Foundation
import Parse

protocol shopManagerDelegate {
    func goToViewController(identifier: String)
}

/**/
/*
class ShopManager

DESCRIPTION
        This class is the model to render data from Shop database and perform a segue to specified destination once the shop
        has been renderd. This is used in many view controllers in order to render the shop data
 
AUTHOR
        Rahul Guni
 
DATE
        07/30/2021
 
*/
/**/

class ShopManager {
    private var currShop: Shop?                 //Shop Object
    private var currProducts: [Product] = []    //All Products of the shop
    var delegate: shopManagerDelegate?          //protocol variable
    
    //Set funnction to set current Shop, passed on from controller
    func setShop(shop: Shop) {
        self.currShop = shop
    }
    
    //Get function to return current Shop
    func getCurrShop() -> Shop {
        return self.currShop!
    }
    
    //Get function to return current shop products
    func getCurrProducts() -> [Product] {
        return self.currProducts
    }
    
    /**/
    /*
    func checkShop(identifier: String)

    NAME

            checkShop - Checks if the user has a shop in Shop Table and performs segue

    SYNOPSIS

            checkShop(identifier: String)
                identifier        --> A segue identifier to perform segue to specified locations

    DESCRIPTION

            This function takes a segue identifier string and performs segue to the given view controller. If no shop is found,
            the user is directed to add shop view controller.
     
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/30/2021

    */
    /**/
    
    func checkShop(identifier: String) {
        //see if user already has a shop, if not go to register shop option.
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().userId, equalTo: currentUser!.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                self.currShop = Shop(shop: object)
                self.getProducts(identifier: identifier)
            }
            else {
                self.delegate?.goToViewController(identifier: "goToAddShopView")
            }
        }
    }
    /*func checkShop(identifier: String)*/
    
    /**/
    /*
    func goToShop(shop: Shop, identifier: String)

    NAME

            goToShop - Perform segue for the given shop object.

    SYNOPSIS

            goToShop(shop: Shop, identifier: String)
                shop        --> A Shop object to render shop details.
                identifier  --> A segue identifier to perform segue to specified locations

    DESCRIPTION

            This function takes a segue identifier string and performs segue to the given view controller for the passed Shop object.
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/30/2021

    */
    /**/
    
    func goToShop(shop: Shop, identifier: String) {
        //see if user already has a shop, if not go to register shop option.
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: shop.getShopId())
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                self.currShop = Shop(shop: object)
                self.getProducts(identifier: identifier)
            }
        }
    }
    /*func goToShop(shop: Shop, identifier: String)*/
    
    /**/
    /*
     func getProducts(identifier: String)

    NAME

            getProducts - Renders all products of the shop and performs segue to given view controller.

    SYNOPSIS

            getProducts(identifier: String)
                identifier  --> A segue identifier to perform segue to specified locations

    DESCRIPTION

            This function takes a segue identifier string and performs segue to the given view controller for the passed Shop object.
            It also fills the products array for products of the specified shop.
    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/30/2021

    */
    /**/
    
    func getProducts(identifier: String) {
        //check if the user has products to load up in the next view
        self.currProducts.removeAll()
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().shopId, equalTo: self.currShop!.getShopId())
        query.order(byAscending: ShopIO.Product().title)
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let products = products {
                for currProduct in products {
                    let tempProduct = Product(product: currProduct)
                    self.currProducts.append(tempProduct)
                }
                self.delegate?.goToViewController(identifier: identifier)
            }
        }
    }
    /*func getProducts(identifier: String)*/
    
}
