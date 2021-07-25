//
//  Product.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//

import Foundation
import UIKit
import Parse

class Product {
    private var objectId: String?
    private var userId: String?
    private var title: String?
    private var metaTitle: String?
    private var slug: String?
    private var summary: String?
    private var type: Int?
    private var price: Double?
    private var discount: Float?
    private var quantity: Int?
    private var content: String?
    private var shopId: String?
    
    init(product productObject: PFObject?){
        self.objectId = productObject?.objectId
        self.userId = productObject!["userId"] as? String
        self.title = productObject!["title"] as? String
        self.summary = productObject!["summary"] as? String
        self.price = productObject!["price"] as? Double
        self.quantity = productObject!["quantity"] as? Int
        self.shopId = productObject!["shopId"] as? String
        self.discount = productObject!["discount"] as? Float
        self.content = productObject!["content"] as? String
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
    
    func getDiscount() -> Float {
        return self.discount!
    }
    
    func getOriginalPrice() -> String {
        return "$" + String(self.price!)
    }
    
    func getOriginalPriceDouble() -> Double {
        return self.price!
    }
    
    func getPrice() -> Double {
        let discount = getDiscount()
        var newPrice = self.price! - ((Double(discount) / 100) * self.price!)
        newPrice = (newPrice * 100).rounded() / 100
        return newPrice
    }
    
    func getPriceAsString() -> String {
        let currPrice = getPrice()
        return "$" + String(currPrice)
    }
    
    func getQuantityAsString() -> String {
        return String(self.quantity!)
    }
    
    func getQuantity() -> Int {
        return self.quantity!
    }
}

