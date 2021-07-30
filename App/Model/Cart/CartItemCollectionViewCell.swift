//
//  CartItemCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/27/21.
//

import UIKit
import RealmSwift

class CartItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDiscount: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productShop: UILabel!
    
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
    }
    
}
