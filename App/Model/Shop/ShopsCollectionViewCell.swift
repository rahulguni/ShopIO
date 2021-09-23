//
//  ShopsCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse

/**/
/*
class MessageTableViewCell

DESCRIPTION
        This class is a UICollectionViewCell class that makes up the cells for Shops Collection View in DiscoverViewController.
AUTHOR
        Rahul Guni
DATE
        07/24/2021
*/
/**/


class ShopsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var shopOwner: UILabel!
    @IBOutlet weak var shopDistance: UILabel!
    
    /**/
    /*
    func setParameters(shop currShop: Shop)

    NAME

            setParameters - Sets the parameter for Shop Collection View Cell.

    SYNOPSIS

            setParameters(shop currShop: Shop)
                currShop       --> A Shop Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes a Shop object to render the right data to collectionview cell. First, the Shop table in database is searched by the Shop model's objectId/shopid variable to render the details of the shop. Then, the distance to ths shop from current location is rendered using geoLocations

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    func setParameters(shop currShop: Shop){
        self.shopTitle.text = currShop.getShopTitle()
        let query = PFQuery(className: ShopIO.User().tableName)
        query.whereKey(ShopIO.User().objectId, contains: currShop.getShopUserid())
        query.getFirstObjectInBackground{ (shop, error) in
            if let myShop = shop {
                let fname = myShop.value(forKey: ShopIO.User().fName) as! String + " "
                let lname = myShop.value(forKey: ShopIO.User().lName) as! String
                self.shopOwner.text = "By: \(fname + lname)"
                self.shopOwner.isHidden = false
            }
        }
        //get shop Image
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
    
    //function to set shop distance, passed on from view controller.
    func setShopDistance(distance: Double) {
        let roundedDistance = (distance  * 0.000621371 * 10).rounded() / 10
        self.shopDistance.text = String(roundedDistance) + " miles"
    }
    
}
