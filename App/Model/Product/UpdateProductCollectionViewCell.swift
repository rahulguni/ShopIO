import UIKit
import Parse

/**/
/*
class UpdateProductCollectionViewCell

DESCRIPTION
        This class is a UICollectionViewCell class that makes up the cells for Products collection view  in UpdateProductCollectionViewController.
 
AUTHOR
        Rahul Guni
 
DATE
        08/06/2021
 
*/
/**/


class UpdateProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDiscount: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    
    
    /**/
    /*
    func setParameters(product currProduct: Product)

    NAME

            setParameters - Sets the parameter for Products Collection View Cell.

    SYNOPSIS

            setParameters(product currProduct: Product)
                currProduct        --> A Product Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes a Proudct object to render the right data to collectionview cell. First, the product is searched in the Products
            table and its corresponding images is searched in the Product_Images table to render the current default picture.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/06/2021

    */
    /**/
    
    func setParameters(product currProduct: Product) {
        productTitle.text = currProduct.getTitle()
        productPrice.text = "Price: " + currProduct.getPriceAsString()
        productDiscount.text = "Discount: " + String(currProduct.getDiscountAmount())
        if(currProduct.getQuantity() < 10) {
            self.productQuantity.textColor = UIColor.red
        }
        else {
            self.productQuantity.textColor = UIColor.black
        }
        productQuantity.text = "Quantity: " + currProduct.getQuantityAsString()
        
        //Get product default image
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().productId, equalTo: currProduct.getObjectId())
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
    /*func setParameters(product currProduct: Product)*/
}
