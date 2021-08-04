//
//  ShopsCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse

class ShopsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var shopRating: UIButton!
    @IBOutlet weak var shopOwner: UILabel!
    
    
    func setParameters(shop currShop: Shop){
        self.shopTitle.text = currShop.getShopTitle()
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", contains: currShop.getShopUserid())
        query.getFirstObjectInBackground{ (shop, error) in
            if let myShop = shop {
                let fname = myShop.value(forKey: "fName") as! String + " "
                let lname = myShop.value(forKey: "lName") as! String
                self.shopOwner.text = "By: \(fname + lname)"
                self.shopOwner.isHidden = false
            }
        }
    }
    
}
