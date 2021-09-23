import Foundation
import UIKit
import Parse
import MapKit

/**/
/*
class Shop

DESCRIPTION
        This class is the model to render data from Shop database. This class also has all the required setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        07/01/2021
*/
/**/

class Shop {
    
    private var objectId: String? //objectId of the shop
    private var userId: String? //objectId of the owner of the shop, foreign key to users table
    private var shopTitle: String?
    private var shopSlogan: String?
    private var shippingCost: Double? //fixed shipping cost for shops.
    private var shopImage: PFFileObject?
    private var geoPoints: PFGeoPoint? //geoPoints of the shop location, added/updated when the shop address is added/updated.
    
    //constructor
    init(shop shopObject: PFObject?){
        self.objectId = shopObject!.objectId
        self.userId = shopObject![ShopIO.Shop().userId] as? String
        self.shopTitle = shopObject![ShopIO.Shop().title] as? String
        self.shopSlogan = shopObject![ShopIO.Shop().slogan] as? String
        self.shippingCost = shopObject![ShopIO.Shop().shippingCost] as? Double
        self.shopImage = shopObject![ShopIO.Shop().shopImage] as? PFFileObject
        self.geoPoints = shopObject![ShopIO.Shop().geoPoints] as? PFGeoPoint
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
