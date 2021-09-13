//
//  Shop.swift
//  App
//
//  Created by Rahul Guni on 7/1/21.
//

import Foundation
import UIKit
import Parse
import MapKit

class Shop {
    
    private var objectId: String?
    private var userId: String?
    private var shopTitle: String?
    private var shopSlogan: String?
    private var shippingCost: Double?
    private var shopImage: PFFileObject?
    private var geoPoints: PFGeoPoint?
    
    init(shop shopObject: PFObject?){
        self.objectId = shopObject!.objectId
        self.userId = shopObject!["userId"] as? String
        self.shopTitle = shopObject!["title"] as? String
        self.shopSlogan = shopObject!["slogan"] as? String
        self.shippingCost = shopObject!["shippingCost"] as? Double
        self.shopImage = shopObject!["shopImage"] as? PFFileObject
        self.geoPoints = shopObject!["geoPoints"] as? PFGeoPoint
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
    
    func getShopImage() -> PFFileObject {
        return self.shopImage!
    }
    
    func getShopUserid() -> String {
        return self.userId!
    }
    
    func getShippingCost() -> Double {
        return (self.shippingCost! * 100).rounded() / 100
    }
    
    func getShippingCostAsString() -> String {
        return String(getShippingCost())
    }
    
    func getGeoPoints() -> PFGeoPoint {
        return self.geoPoints!
    }
    
}
