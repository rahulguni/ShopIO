import Foundation
import Parse

/**/
/*
class Order

DESCRIPTION
        This class is the model to render data from Order database. This class also has all the required setter and getter properies for the parameters.
 
AUTHOR
        Rahul Guni
 
DATE
        09/03/2021
 
*/
/**/

class Order {
    private var objectId: String?       //objectId of the order
    private var subTotal: Double?
    private var total: Double?
    private var userId: String?
    private var tax: Double?
    private var addressId: String?
    private var itemDiscount: Double?
    private var pickUp: Bool?
    private var shopId: String?         //shopId of the receiever of order, foreign key to Shop table 
    private var createdAt: Date?
    private var fulfilled: Bool?
    
    //constructor
    init(order: PFObject) {
        self.objectId = order.objectId!
        self.subTotal = order.value(forKey: ShopIO.Order().subTotal) as? Double
        self.total = order.value(forKey: ShopIO.Order().total) as? Double
        self.userId = order.value(forKey: ShopIO.Order().userId) as? String
        self.tax = order.value(forKey: ShopIO.Order().tax) as? Double
        self.addressId = order.value(forKey: ShopIO.Order().addressId) as? String
        self.itemDiscount = order.value(forKey: ShopIO.Order().itemDiscount) as? Double
        self.pickUp = order.value(forKey: ShopIO.Order().pickUp) as? Bool
        self.shopId = order.value(forKey: ShopIO.Order().shopId) as? String
        self.createdAt = order.value(forKey: ShopIO.Order().createdAt) as? Date
        self.fulfilled = order.value(forKey: ShopIO.Order().fulfilled) as? Bool
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getSubTotal() -> Double {
        return (self.subTotal! * 100).rounded() / 100
    }
    
    func getTotal() -> Double {
        return (self.total! * 100).rounded() / 100
    }
    
    func getUsertId() -> String {
        return self.userId!
    }
    
    func getTax() -> Double {
        return (self.tax! * 100).rounded() / 100
    }
    
    func getAddressId() -> String {
        return self.addressId!
    }
    
    func getItemDiscount() -> Double {
        return (self.itemDiscount! * 100).rounded() / 100
    }
    
    func getShopId() -> String {
        return self.shopId!
    }
    
    func getPickUp() -> Bool {
        return self.pickUp!
    }
    
    func getOrderDate() -> String {
        return String(self.createdAt!.debugDescription.prefix(10))
    }
    
    func getFulfilled() -> Bool {
        return self.fulfilled!
    }
}
