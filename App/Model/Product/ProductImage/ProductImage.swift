import Foundation
import UIKit
import Parse

/**/
/*
class ProductImage
 
DESCRIPTION
        This class is the model to render data from Product_Image database. This class also has all the setter and getter properies for the parameters.
 
AUTHOR
        Rahul Guni
 
DATE
        08/14/2021
 
*/
/**/

class ProductImage{
    private var currImage: PFFileObject     //Image of the product, rendered as a PFFileObject used in ProductReviewController
    private var objectId: String            //ObjectId of the image
    private var isDefault: Bool             //Decides the current display picture
    private var currUIImage: UIImage?       //UIImage fetched from currImage
    
    //constructor
    init(image productImage: PFObject){
        self.objectId = productImage.objectId! as String
        self.isDefault = productImage[ShopIO.Product_Images().isDefault] as! Bool
        self.currImage = productImage[ShopIO.Product_Images().productImage] as! PFFileObject
    }
    
    func getImage() -> PFFileObject {
        return self.currImage
    }
    
    func getObjectId() -> String {
        return self.objectId
    }
    
    func getDefaultStatus() -> Bool {
        return self.isDefault
    }
    
    func setImage(image currImage: UIImage) {
        self.currUIImage = currImage
    }
    
    func getUIImage() -> UIImage? {
        return self.currUIImage
    }
    
}
