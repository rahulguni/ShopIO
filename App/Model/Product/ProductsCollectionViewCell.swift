//
//  ProductsCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/21/21.
//

import UIKit
import Parse

class ProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
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
        let query = PFQuery(className: "Product_Images")

        query.whereKey("productId", equalTo: currProduct.getObjectId())
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
