import UIKit
import Parse

/**/
/*
class MessageTableViewCell

DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Products Table in MyOrdersViewController.
AUTHOR
        Rahul Guni
DATE
        09/04/2021
*/
/**/

class MyOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var requestedQuantity: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
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
    func setParameters(orderItem: OrderItem)

    NAME

            setParameters - Sets the parameter for My Orders Table View Cell.

    SYNOPSIS

            setParameters(orderItem: OrderItem)
                orderItem        --> An OrderItem Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes an OrderItem object and searches through the Products table using the OrderItem object's productId variable.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/04/2021

    */
    /**/
    
    func setParameters(orderItem: OrderItem){
        self.requestedQuantity.text = "Requested Quantity: " + String(orderItem.getQuantity())
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().objectId, equalTo: orderItem.getProductId())
        query.getFirstObjectInBackground{(product, error) in
            if let product = product {
                let currProduct = Product(product: product)
                self.getProductImage(product: currProduct)
                self.productTitle.text = currProduct.getTitle()
                self.priceLabel.text = "Current Price: $" + String(currProduct.getPrice())
                if(orderItem.getQuantity() > currProduct.getQuantity()) {
                    self.requestedQuantity.textColor = UIColor.red
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    /* func setParameters(orderItem: OrderItem) */
    
    /**/
    /*
    private func getProductImage(product: Product)

    NAME

            getProductImage - Sets the default image fot product in the table view cell

    SYNOPSIS

            getProductImage(product: Product)
                product        --> A Product Object to extract the objectId

    DESCRIPTION

            This function takes a Product object and searches through the Product_Images table using the Product object's objectId variable and renders the default display picture.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/04/2021

    */
    /**/
    
    private func getProductImage(product: Product) {
        let query = PFQuery(className: ShopIO.Product_Images().tableName)

        query.whereKey(ShopIO.Product_Images().productId, equalTo: product.getObjectId())
        query.whereKey(ShopIO.Product_Images().isDefault, equalTo: "True")
        
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                let productImage = object?.value(forKey: ShopIO.Product_Images().productImage)
                let tempImage = productImage as! PFFileObject
                tempImage.getDataInBackground{(imageData: Data?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let imageData = imageData {
                        self.productImage.image = UIImage(data: imageData)
                    }
                }
            }
            else {
               print("No default picture")
            }
        }
    }
    /*private func getProductImage(product: Product)*/
}
