//
//  ProductImage.swift
//  App
//
//  Created by Rahul Guni on 8/14/21.
//

import Foundation
import UIKit
import Parse

class ProductImage{
    private var currImage: PFFileObject
    private var objectId: String
    private var isDefault: Bool
    private var currUIImage: UIImage?
    
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
