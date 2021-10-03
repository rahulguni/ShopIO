import Foundation
import UIKit
import Parse

/**/
/*
class Product

DESCRIPTION
        This class is the model to render data from Product table in database. This class also has all the setter and getter properties for the parameters.
AUTHOR
        Rahul Guni
DATE
        07/15/2021
*/
/**/

class Product {
    private var objectId: String?   //objectId of the product
    private var userId: String?     //userId of the product owner, foreign key to users table
    private var title: String?
    private var summary: String?
    private var price: Double?
    private var discount: Double?
    private var quantity: Int?
    private var content: String?
    private var shopId: String?
    private var updatedAt: Date?
    
    //constructor
    init(product productObject: PFObject?){
        self.objectId = productObject?.objectId
        self.userId = productObject![ShopIO.Product().userId] as? String
        self.title = productObject![ShopIO.Product().title] as? String
        self.summary = productObject![ShopIO.Product().summary] as? String
        self.price = productObject![ShopIO.Product().price] as? Double
        self.quantity = productObject![ShopIO.Product().quantity] as? Int
        self.shopId = productObject![ShopIO.Product().shopId] as? String
        self.discount = productObject![ShopIO.Product().discount] as? Double
        self.content = productObject![ShopIO.Product().content] as? String
        self.updatedAt = productObject!.value(forKey: ShopIO.Product().updatedAt) as? Date
    }
    
    func setProduct(product productObject: Product) {
        self.title = productObject.getTitle()
        self.summary = productObject.getSummary()
        self.price = productObject.getOriginalPriceDouble()
        self.quantity = productObject.getQuantity()
        self.discount = productObject.getDiscount()
        self.content = productObject.getContent()
    }
    
    func setObjectId(product productObject: PFObject?){
        self.objectId = productObject?.objectId
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getTitle() -> String {
        return self.title!
    }
    
    func getUserId() -> String {
        return self.userId!
    }
    
    func getShopId() -> String {
        return self.shopId!
    }
    
    func getSummary() -> String {
        return self.summary!
    }
    
    func getContent() -> String {
        return self.content!
    }
    
    func getDiscount() -> Double {
        return self.discount!
    }
    
    func getOriginalPrice() -> String {
        return "$" + String(format: "%.2f", self.price!)
    }
    
    func getOriginalPriceDouble() -> Double {
        return self.price!
    }
    
    //Function to get the price after discount
    func getPrice() -> Double {
        let discount = getDiscount()
        var newPrice = self.price! - ((Double(discount) / 100) * self.price!)
        newPrice = (newPrice * 100).rounded() / 100
        return newPrice
    }
    
    func getPriceAsString() -> String {
        let currPrice = getPrice()
        return "$" + String(format: "%.2f", currPrice)
    }
    
    func getQuantityAsString() -> String {
        return String(self.quantity!)
    }
    
    func getQuantity() -> Int {
        return self.quantity!
    }
    
    //Function to get discount amount from discount percentage.
    func getDiscountAmount() -> Double {
        let discount = getDiscount()
        let discountAmount = ((Double(discount) / 100) * self.price!)
        return (discountAmount * 100).rounded() / 100
    }
    
    func getUpdateDate() -> Date {
        return self.updatedAt!
    }
}

