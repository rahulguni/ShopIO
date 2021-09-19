//
//  OrderModel.swift
//  App
//
//  Created by Rahul Guni on 9/3/21.
//

import Foundation
import Parse

class Order {
    private var objectId: String?
    private var subTotal: Double?
    private var total: Double?
    private var userId: String?
    private var tax: Double?
    private var addressId: String?
    private var itemDiscount: Double?
    private var pickUp: Bool?
    private var shopId: String?
    private var createdAt: Date?
    private var fulfilled: Bool?
    
    init(order: PFObject) {
        self.objectId = order.objectId!
        self.subTotal = order.value(forKey: "subTotal") as? Double
        self.total = order.value(forKey: "total") as? Double
        self.userId = order.value(forKey: "userId") as? String
        self.tax = order.value(forKey: "tax") as? Double
        self.addressId = order.value(forKey: "addressId") as? String
        self.itemDiscount = order.value(forKey: "itemDiscount") as? Double
        self.pickUp = order.value(forKey: "pickUp") as? Bool
        self.shopId = order.value(forKey: "shopId") as? String
        self.createdAt = order.value(forKey: "createdAt") as? Date
        self.fulfilled = order.value(forKey: "fulfilled") as? Bool
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
