//
//  UpdateProductCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/6/21.
//

import UIKit

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
    }

}
