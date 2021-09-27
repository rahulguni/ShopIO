import UIKit
import Parse

/**/
/*
class FollowedShopCollectionViewCell

DESCRIPTION
        This class is a UICollectionViewCell class that makes up the cells for Followed Shops Collection View in DiscoverViewController.
AUTHOR
        Rahul Guni
DATE
        08/05/2021
*/
/**/

class FollowedShopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var shopTitle: UILabel!
    
    /**/
    /*
    func setParameters(shop currShop: Shop)

    NAME

            setParameters - Sets the parameter for Followed Shop Collection View Cell.

    SYNOPSIS

            setParameters(shop currShop: Shop)
                currShop       --> A Shop Object to fill the table cells with the correct parameters

    DESCRIPTION

            This function takes a Shop object to render the right data to collectionview cell. First, the Shop table in database is
            searched by the Shop model's objectId/shopid variable to render the details of the shop.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/05/2021

    */
    /**/
    
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
    /*func setParameters(shop currShop: Shop)*/
}
