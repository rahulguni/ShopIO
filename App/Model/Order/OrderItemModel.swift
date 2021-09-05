//
//  OrderItemModel.swift
//  App
//
//  Created by Rahul Guni on 9/4/21.
//

import Foundation
import Parse

class OrderItem{
    private var objectId: String?
    private var orderId: String?
    private var price: Double?
    private var productId: String?
    private var quantity: Int?
    
    init(orderItem: PFObject) {
        self.objectId = orderItem.objectId!
        self.orderId = orderItem.value(forKey: "orderId") as? String
        self.price = orderItem.value(forKey: "price") as? Double
        self.productId = orderItem.value(forKey: "productId") as? String
        self.quantity = orderItem.value(forKey: "quantity") as? Int
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
