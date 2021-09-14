//
//  ProductSearchTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/14/21.
//

import UIKit
import Parse

class ProductSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var quantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(product: Product) {
        self.title.text = product.getTitle()
        if(product.getDiscount() != 0) {
            let attributeString = makeStrikethroughText(product: product)
            self.discount.attributedText = attributeString
            self.price.text = product.getPriceAsString()
        }
        else {
            self.discount.isHidden = true
            self.price.isHidden = true
            self.originalPrice.isHidden = false
            self.originalPrice.text = product.getOriginalPrice()
        }
        self.quantity.text = "Available Quantity: \(product.getQuantity())"
        getShop(shopId: product.getShopId())
        getProductPhoto(productId: product.getObjectId())
    }
    
    private func getShop(shopId: String){
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: shopId)
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.shopName.text = Shop(shop: shop).getShopTitle()
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

}
