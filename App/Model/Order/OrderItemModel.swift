import Foundation
import Parse

/**/
/*
class OrderItem

DESCRIPTION
        This class is the model to render data from Order_Item database. This class also has all the required setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        09/04/2021
*/
/**/

class OrderItem{
    private var objectId: String?
    private var orderId: String?
    private var price: Double?
    private var productId: String?
    private var quantity: Int?
    
    //constructor
    init(orderItem: PFObject) {
        self.objectId = orderItem.objectId!
        self.orderId = orderItem.value(forKey: ShopIO.Order_Item().orderId) as? String
        self.price = orderItem.value(forKey: ShopIO.Order_Item().price) as? Double
        self.productId = orderItem.value(forKey: ShopIO.Order_Item().productId) as? String
        self.quantity = orderItem.value(forKey: ShopIO.Order_Item().quantity) as? Int
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getOrderId() -> String {
        return self.orderId!
    }
    
    func getPrice() -> Double {
        return self.price!
    }
    
    func getProductId() -> String {
        return self.productId!
    }
    
    func getQuantity() -> Int {
        return self.quantity!
    }
}
