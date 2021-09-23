import UIKit

/**/
/*
class ImageCollectionViewCell

DESCRIPTION
        This class is a UICollectionViewCell class that makes up the cells for Product Images collection view  in MyProductViewController.
AUTHOR
        Rahul Guni
DATE
        08/12/2021
*/
/**/

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    func setImage(image currImage: UIImage) {
        self.productImage.image = currImage
    }
}
