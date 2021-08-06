//
//  FollowedShopCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/5/21.
//

import UIKit
import Parse

class FollowedShopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var shopTitle: UILabel!
    
    func setParameters(shop currShop: Shop) {
        self.shopTitle.text = currShop.getShopTitle()
    }
    
}
