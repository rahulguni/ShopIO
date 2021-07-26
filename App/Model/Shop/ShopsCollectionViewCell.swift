//
//  ShopsCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit

class ShopsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var shopRating: UIButton!
    
    func setParameters(shop currShop: Shop){
        self.shopTitle.text = currShop.getShopTitle()
    }
    
}
