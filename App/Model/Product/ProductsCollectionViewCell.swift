//
//  ProductsCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/21/21.
//

import UIKit

class ProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    
    
    func setParameters(Product currProduct: Product) {
        self.name.text = currProduct.getTitle()
        if(currProduct.getDiscount() != 0) {
            let attributeString = makeStrikethroughText(product: currProduct)
            self.discount.attributedText = attributeString
            self.price.text = currProduct.getPriceAsString()
        }
        else {
            discount.isHidden = true
            price.isHidden = true
            originalPrice.isHidden = false
            originalPrice.text = currProduct.getOriginalPrice()
        }
    }
    
}
