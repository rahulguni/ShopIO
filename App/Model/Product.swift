//
//  Product.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//

import Foundation
import UIKit
import Parse

struct Product {
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
    }
    
    mutating func setObjectId(product productObject: PFObject?){
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
    
    func getPrice() -> Double {
        return self.price!
    }
    
    func getQuantity() -> String {
        return String(self.quantity!)
    }
}
