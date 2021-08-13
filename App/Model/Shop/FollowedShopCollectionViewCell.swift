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
        let shopImagecover = currShop.getShopImage()
        let tempImage = shopImagecover
        tempImage.getDataInBackground{(imageData: Data?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let imageData = imageData {
                self.shopImage.image = UIImage(data: imageData)
            }
        }
    }
}
