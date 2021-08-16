//
//  CartItemCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/27/21.
//

import UIKit
import Parse
import RealmSwift
import SwipeCellKit

class CartItemCollectionViewCell: SwipeCollectionViewCell {
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDiscount: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productShop: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    func setParameters(product currProduct: CartItem) {
        
        let totalPrice = (currProduct.price!) * ((Double)(currProduct.quantity!))
        let totalDiscount = (currProduct.discount!) * ((Double) (currProduct.quantity!))
        
        self.productTitle.text = currProduct.productTitle!
        self.productQuantity.text = String(currProduct.quantity!)
        self.productDiscount.text = String(format: "%.2f", totalDiscount)
        if(currProduct.quantity! > 1) {
            self.productPrice.text = "$" + String(format: "%.2f", totalPrice) + " (@ $" + String(currProduct.price!) + "/each)"
        }
        else {
            self.productPrice.text = "$" + String(format: "%.2f", totalPrice)
        }
        
        let query = PFQuery(className: "Product_Images")

        query.whereKey("productId", equalTo: currProduct.productId!)
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
