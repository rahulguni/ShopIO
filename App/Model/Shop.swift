//
//  Shop.swift
//  App
//
//  Created by Rahul Guni on 7/1/21.
//

import Foundation
import UIKit
import Parse

class Shop {
    
    private var objectId: String?
    private var userId: String?
    private var shopTitle: String?
    private var shopSlogan: String?
    private var shopImage: UIImage?
    private var shopOwner: String?
    
    
    init(shop shopObject: PFObject?){
        self.objectId = shopObject!.objectId
        self.userId = shopObject!["userId"] as? String
        self.shopTitle = shopObject!["title"] as? String
        self.shopSlogan = shopObject!["slogan"] as? String
    }
    
    init(userId: String?) {
        self.userId = userId
    }
    
    func getShopId() -> String {
        return self.objectId!
    }
    
    func getShopTitle() -> String{
        return self.shopTitle!
    }
    
    func getShopSlogan() -> String {
        return self.shopSlogan!
    }
    
    func getShopImage() -> UIImage {
        return self.shopImage!
    }
    
    func getShopUserid() -> String {
        return self.userId!
    }
 
}
