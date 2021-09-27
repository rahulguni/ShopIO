import UIKit
import Parse

/**/
/*
class ProductsCollectionViewCell

DESCRIPTION
        This class is a UICollectionView class that makes up the collection view of Products in MyStoreViewController.
 
AUTHOR
        Rahul Guni
 
DATE
        07/24/2021
 
*/
/**/

class ProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    /**/
    /*
    func setParameters(Product currProduct: Product)

    NAME

            setParameters - Sets the parameter for Product View Collection

    SYNOPSIS

            setParameters(Product currProduct: Product)
                currProduct     --> A Product object to fill in the labels with correct data.

    DESCRIPTION

            This function takes an object from the Product model and fills in the labels according to the data.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    func setParameters(Product currProduct: Product) {
        setPriceLabelsVisibility(forDiscount: true, forOriginal: true)
        
        self.name.text = currProduct.getTitle()
        if(currProduct.getDiscount() != 0) {
            let attributeString = makeStrikethroughText(product: currProduct)
            self.discount.attributedText = attributeString
            self.price.text = currProduct.getPriceAsString()
            setPriceLabelsVisibility(forDiscount: false, forOriginal: true)
        }
        else {
            setPriceLabelsVisibility(forDiscount: true, forOriginal: false)
            originalPrice.text = currProduct.getOriginalPrice()
        }
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
    /*func setParameters(Product currProduct: Product) */
    
    /**/
    /*
     private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool)

    NAME

            setPriceLabelsVisibility - Sets the labels according to the discount amount- whether or not the discount amount exists.

    SYNOPSIS

            setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool)
                forDiscount     --> A boolean variable to set the visibilty of labels
                forOriginal     --> A boolean variable to set the visibilty of labels

    DESCRIPTION

            This function takes two boolean variables in order to set the visibility of price, discount and originalPrice labels on
            the condition of whether or not discount exists for the given product.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool) {
        self.price.isHidden = forDiscount
        self.discount.isHidden = forDiscount
        self.originalPrice.isHidden = forOriginal
    }
    /* private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool)*/
    
}
