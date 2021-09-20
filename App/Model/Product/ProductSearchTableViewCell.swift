//
//  ProductSearchTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/14/21.
//

import UIKit
import Parse
import MapKit

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
    
    private func getRating(productId: String) {
        var ratings: [ProductReview] = []
        let query = PFQuery(className: "Product_Review")
        query.whereKey("productId", equalTo: productId)
        query.order(byDescending: "updatedAt")
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
                if(totalReview > 0) {
                    self.shopName.text = "Rating: \(totalReview) / 5.0 (\(reviewCount))"
                }
                else {
                    self.shopName.text = "Rating: N/A"
                }
            }
        }
    }
    
    private func getShop(shopId: String){
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: shopId)
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
    
    private func setPriceLabelsVisibility(forDiscount: Bool, forOriginal: Bool) {
        self.price.isHidden = forDiscount
        self.discount.isHidden = forDiscount
        self.originalPrice.isHidden = forOriginal
    }

}
