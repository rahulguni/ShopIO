import UIKit
import Parse
import RealmSwift
import SwipeCellKit

/**/
/*
class CartItemCollectionViewCell

DESCRIPTION
        This class is a SwipeCollectionView class that makes up the cells for Cart Collection View in CartViewController.
        link: https://github.com/SwipeCellKit/SwipeCellKit
 
AUTHOR
        Rahul Guni
 
DATE
        07/27/2021
 
*/
/**/

class CartItemCollectionViewCell: SwipeCollectionViewCell {
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDiscount: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productShop: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    /**/
    /*
    func setParameters(product currProduct: CartItem)

    NAME

            setParameters - Sets the parameter for Order Collection View Cell.

    SYNOPSIS

            setParameters(product currProduct: CartItem)
                currProduct        --> A CartItem Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes a CartItem object to render the right data to tableview cell. First, the Product
            table in database is searched by the CartItem model's productId variable to render the necessary
            details of the product. Then, using the productId, the Product_Images table is searched to render the
            Product's display image. Finally, using the shopId, the Shop table is searched to render the product's
            shop details.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/27/2021

    */
    /**/
    
    func setParameters(product currProduct: CartItem) {
        
        let totalPrice = (currProduct.price!) * ((Double)(currProduct.quantity!))
        let totalDiscount = (currProduct.discount!) * ((Double) (currProduct.quantity!))
        
        self.productTitle.text = currProduct.productTitle!
        self.productQuantity.text = "Quantity: " + String(currProduct.quantity!)
        self.productDiscount.text = "Discount: " + String(format: "%.2f", totalDiscount)
        if(currProduct.quantity! > 1) {
            self.productPrice.text = "$" + String(format: "%.2f", totalPrice) + " (@ $" + String(currProduct.price!) + "/each)"
        }
        else {
            self.productPrice.text = "$" + String(format: "%.2f", totalPrice)
        }
        
        //get shop
        let productQuery = PFQuery(className: ShopIO.Product().tableName)
        productQuery.whereKey(ShopIO.Product().objectId, equalTo: currProduct.productId!)
        productQuery.getFirstObjectInBackground{(product, error) in
            if let product = product {
                let shopQuery = PFQuery(className: ShopIO.Shop().tableName)
                shopQuery.whereKey(ShopIO.Shop().objectId, equalTo: product.value(forKey: ShopIO.Product().shopId) as! String)
                shopQuery.getFirstObjectInBackground{(shop, error) in
                    if let shop = shop {
                        let currShop = Shop(shop: shop)
                        self.productShop.text = currShop.getShopTitle()
                    }
                }
            }
        }
        
        
        //get product image
        let imageQuery = PFQuery(className: ShopIO.Product_Images().tableName)

        imageQuery.whereKey(ShopIO.Product_Images().productId, equalTo: currProduct.productId!)
        imageQuery.whereKey(ShopIO.Product_Images().isDefault, equalTo: "True")
        
        imageQuery.getFirstObjectInBackground{(object, error) in
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
        }
    }
    /*func setParameters(product currProduct: CartItem)*/
    
}
