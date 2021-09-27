import UIKit
import Parse

/**/
/*
class OrdersTableViewCell

DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Order Table in OrdersViewController.
 
AUTHOR
        Rahul Guni
 
DATE
        09/03/2021
 
*/
/**/

class OrdersTableViewCell: UITableViewCell {
    @IBOutlet weak var orderUser: UILabel!
    @IBOutlet weak var orderUserImage: UIImageView!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**/
    /*
    func setParameters(order: Order, forUser: Bool)

    NAME

            setParameters - Sets the parameter for Orders Table View Cell.

    SYNOPSIS

            setParameters(order: Order, forUser: Bool)
                currOrder        --> An Order Object to fill the table cells with the correct parameters
                forUser          --> A boolean variable to fill the table cell accordingly

    DESCRIPTION

            This function takes an Order object to render the right data to tableview cell. First, the Order table
            in database is searched by the Order model's objectId variable to render the details of the order. Then,
            according to the boolean variable set, either the Shop name or the user Details is rendered.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    func setParameters(order: Order, forUser: Bool){
        self.orderTotal.text = "Total: $" + String(order.getSubTotal())
        self.orderDate.text = "Date: \(order.getOrderDate())"
        setStatus(order: order)
        if(forUser) {
            getOrderShop(order: order)
        }
        else{
            getOrderUser(order: order)
        }
    }
    /* func setParameters(order: Order, forUser: Bool) */
    
    /**/
    /*
    private func setStatus(order: Order)

    NAME

            setStatus - Sets the label for status of the order.

    SYNOPSIS

            setStatus(order: Order, forUser: Bool)
                currOrder        --> An Order Object to extract the order's objectId

    DESCRIPTION

            This function takes an Order object to render the right data to tableview cell. It searches whether or not
            the order is fulfilled. In case the order is deleted by shop, there will be no items in the Order_Item table.
            So, this function searches the Order_Items table to check if the order is fulfilled ot deleted, and renders
            it in the completion label.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func setStatus(order: Order) {
        if(order.getFulfilled() == false) {
            self.orderStatus.text = "Pending"
            self.orderStatus.isHidden = false
        }
        else {
            let query = PFQuery(className: ShopIO.Order_Item().tableName)
            query.whereKey(ShopIO.Order_Item().orderId, equalTo: order.getObjectId())
            query.findObjectsInBackground{(products, error) in
                if let products = products {
                    if(products.count > 0) {
                        self.orderStatus.text = "Fulfilled"
                    }
                    else {
                        self.orderStatus.text = "Deleted"
                    }
                    self.orderStatus.isHidden = false
                }
                else {
                    self.orderStatus.isHidden = true
                }
            }
        }
    }
    /* private func setStatus(order: Order)*/
    
    /**/
    /*
    private func getOrderUser(order: Order)

    NAME

            getOrderUser - Sets the label for user of the order.

    SYNOPSIS

                getOrderUser(order: Order)
                currOrder        --> An Order Object to extract the order's userId

    DESCRIPTION

            This function takes an Order object to render the right data to tableview cell. It searches the user's table
            through the userId variable and renders the user's data.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getOrderUser(order: Order){
        let query = PFQuery(className: ShopIO.User().tableName)
        query.whereKey(ShopIO.User().objectId, equalTo: order.getUsertId())
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                let currUser = User(userID: user)
                self.orderUser.text = "By: " + currUser.getName()
                let userImage = currUser.getImage()
                userImage.getDataInBackground{(image, error) in
                    if let image = image {
                        self.orderUserImage.image = UIImage(data: image)
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    /*private func getOrderUser(order: Order)*/
    
    /**/
    /*
    private func getOrderShop(order: Order)

    NAME

            getOrderShop - Sets the label for the shop of the order.

    SYNOPSIS

                getOrderShop(order: Order)
                currOrder        --> An Order Object to extract the order's shopId

    DESCRIPTION

            This function takes an Order object to render the right data to tableview cell. It searches the shop's table through
            the shopId variable and renders the shop's data.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/03/2021

    */
    /**/
    
    private func getOrderShop(order: Order) {
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: order.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                let currShop = Shop(shop: shop)
                self.orderUser.text = currShop.getShopTitle()
                let shopImage = currShop.getShopImage()
                shopImage.getDataInBackground{(image, error) in
                    if let image = image {
                        self.orderUserImage.image = UIImage(data: image)
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
            }
            else{
                print(error.debugDescription)
            }
        }
    }
    /*private func getOrderShop(order: Order)*/

}
