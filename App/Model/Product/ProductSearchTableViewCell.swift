import UIKit
import Parse
import MapKit

/**/
/*
class ProductSearchTableViewCell

DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Search Products Table view  in SearchViewController
        as well as from the search function in a certain store.
 
AUTHOR
        Rahul Guni
 
DATE
        09/14/2021
 
*/
/**/

class ProductSearchTableViewCell: UITableViewCell, CLLocationManagerDelegate {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var quantity: UILabel!
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setPriceLabelsVisibility(forDiscount: true, forOriginal: true)
        locationManager.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**/
    /*
    func setParameters(product: Product, forShop: Bool)

    NAME

            setParameters - Sets the parameter for Search Products Table View Cell.

    SYNOPSIS

            setParameters(product: Product, forShop: Bool)
                product        --> A Product Object to fill the table cells with the correct parameters
                forShop        --> A boolean variable to determine after which view controller the table view cell is rendered.

    DESCRIPTION

            This function takes a Product object to render the right data to tableview cell. First, the Product table in database
            is searched by the Product model's objectId variable to render the details of the product. Then, using the shopId and
            productId, the Shop table and Product_Review table is searched to render the shop's information and product's ratings
            respectively.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    func setParameters(product: Product, forShop: Bool) {
        self.title.text = product.getTitle()
        if(product.getDiscount() != 0) {
            let attributeString = makeStrikethroughText(product: product)
            self.discount.attributedText = attributeString
            self.price.text = product.getPriceAsString()
            setPriceLabelsVisibility(forDiscount: false, forOriginal: true)
        }
        else {
            setPriceLabelsVisibility(forDiscount: true, forOriginal: false)
            self.originalPrice.text = product.getOriginalPrice()
        }
        self.quantity.text = "Available Quantity: \(product.getQuantity())"
        if(!forShop) {
            getShop(shopId: product.getShopId())
        }
        else {
            getRating(productId: product.getObjectId())
        }
        getProductPhoto(productId: product.getObjectId())
    }
    /*func setParameters(product: Product, forShop: Bool)*/
    
    /**/
    /*
     private func getRating(productId: String)

    NAME

            getRating - Sets the parameter for Search Products Table View Cell's Product ratings label.

    SYNOPSIS

            getRating(productId: String)
                productId        --> productId string to search the Product_Review table

    DESCRIPTION

            This function is used inside of setParameters function to render the current product's rating

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func getRating(productId: String) {
        var ratings: [ProductReview] = []
        let query = PFQuery(className: ShopIO.Product_Review().tableName)
        query.whereKey(ShopIO.Product_Review().productId, equalTo: productId)
        query.order(byDescending: ShopIO.Product_Review().updatedAt)
        query.findObjectsInBackground{(reviews, errors) in
            if let reviews = reviews {
                var totalReview: Double = 0.0
                var reviewCount: Int = 0
                
                for review in reviews {
                    let currReview = ProductReview(reviewObject: review)
                    totalReview += Double(currReview.getRating())
                    reviewCount += 1
                    ratings.append(currReview)
                    totalReview = ((totalReview / Double(ratings.count)) * 100).rounded() / 100
                }
                //If product review does not exist, set the rating label to N/A.
                if(totalReview > 0) {
                    self.shopName.text = "Rating: \(totalReview) / 5.0 (\(reviewCount))"
                }
                else {
                    self.shopName.text = "Rating: N/A"
                }
            }
        }
    }
    /* private func getRating(producyId: String)*/
    
    /**/
    /*
     private func getShop(shopId: String)

    NAME

            getShop - Sets the parameter for Search Products Table View Cell's Shop Label.

    SYNOPSIS

            getShop(shopId: String)
                shopId        --> shopId string to search the Shop table

    DESCRIPTION

            This function is used inside of setParameters function to render the current product's shop.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func getShop(shopId: String){
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: shopId)
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                let currShop = Shop(shop: shop)
                let userCoordinate = CLLocation(latitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)
                let shopCoordinate = CLLocation(latitude: currShop.getGeoPoints().latitude, longitude: currShop.getGeoPoints().longitude)
                let distanceInMeters = userCoordinate.distance(from: shopCoordinate) // result is in meters
                let roundedDistance = (distanceInMeters  * 0.000621371 * 10).rounded() / 10
                self.shopName.text = currShop.getShopTitle() + " (" + String(roundedDistance) + " miles)"
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    /* private func getShop(shopId: String) */
    
    /**/
    /*
     private func getProductPhoto(productId: String)

    NAME

            getProductPhoto - Sets the parameter for Search Products Table View Cell's Product photo.

    SYNOPSIS

            getProductPhoto(productId: String)
                productId        --> productId string to search the Product_Images table

    DESCRIPTION

            This function is used inside of setParameters function to render the current product's default picture.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func getProductPhoto(productId: String) {
        let query = PFQuery(className: "Product_Images")

        query.whereKey("productId", equalTo: productId)
        query.whereKey("isDefault", equalTo: "True")
        
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                let productImage = object?.value(forKey: "productImage")
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
    /*private func getProductPhoto(productId: String)*/
    
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

            09/14/2021

    */
    /**/
    
    private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool) {
        self.price.isHidden = forDiscount
        self.discount.isHidden = forDiscount
        self.originalPrice.isHidden = forOriginal
    }
    /*private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool)*/

}
