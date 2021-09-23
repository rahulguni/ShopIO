import UIKit
import Parse

/**/
/*
class MessageTableViewCell

DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Requests Table in RequestsViewController.
AUTHOR
        Rahul Guni
DATE
        08/07/2021
*/
/**/

class RequestsTableViewCell: UITableViewCell {
    @IBOutlet weak var requestUser: UILabel!
    @IBOutlet weak var requestProduct: UILabel!
    
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
    func setParameters(request currRequest: Request)

    NAME

            setParameters - Sets the parameter for Requests Table View Cell.

    SYNOPSIS

            setParameters(request currRequest: Request)
                currRequest        --> A Request Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes a Request object to render the right data to tableview cell. First, the User table in database is searched by the Request model's userId variable to render the full name of the user who has sent the request. Then, using the productId, the Product table is searched to render the requested Product.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    func setParameters(request currRequest: Request) {
        let userQuery = PFQuery(className: ShopIO.User().tableName)
        userQuery.whereKey(ShopIO.User().objectId, equalTo: currRequest.getUserId())
        userQuery.getFirstObjectInBackground{(user, error) in
            if(user != nil) {
                let name = (user?.value(forKey: ShopIO.User().fName) as! String) + " " + (user?.value(forKey: ShopIO.User().lName) as! String)
                self.requestUser.text = "From: \(name)"
            }
        }
        let productQuery = PFQuery(className: ShopIO.Product().tableName)
        productQuery.whereKey(ShopIO.Product().objectId, equalTo: currRequest.getProductId())
        productQuery.getFirstObjectInBackground{(product, error) in
            if(product != nil) {
                let product = product?.value(forKey: ShopIO.Product().title) as? String
                self.requestProduct.text = "Product: \(product!)"
            }
        }
    }
    /* func setParameters(request currRequest: Request) */

}
