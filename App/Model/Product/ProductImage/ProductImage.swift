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
    private var currImage: PFFileObject
    private var objectId: String
    private var isDefault: Bool
    private var currUIImage: UIImage?
    
    //constructor
    init(image productImage: PFObject){
        self.objectId = productImage.objectId! as String
        self.isDefault = productImage["isDefault"] as! Bool
        self.currImage = productImage["productImage"] as! PFFileObject
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
