//
//  UpdateProductCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/6/21.
//

import UIKit
import Parse

class UpdateProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDiscount: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    
    func setParameters(product currProduct: Product) {
        productTitle.text = currProduct.getTitle()
        productPrice.text = currProduct.getPriceAsString()
        productDiscount.text = String(currProduct.getDiscountAmount())
        if(currProduct.getQuantity() < 10) {
            self.productQuantity.textColor = UIColor.red
        }
        else {
            self.productQuantity.textColor = UIColor.black
        }
        productQuantity.text = currProduct.getQuantityAsString()
        
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
}
