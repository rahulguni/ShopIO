//
//  CartModel.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import Foundation

class Cart {
    private final var userId = currentUser!.objectId!
    private var sessionId: String?
    private var subTotal: Double?
    private var itemDiscount: Double?
    private var tax: Double?
    private var shipping: Double?
    private var total: Double?
    private var addressId: String?
    
    init(cartItems: [CartItem]){
        var currTotal = 0.0
        for item in cartItems {
            currTotal += (item.price!) * Double(item.quantity!)
        }
        self.subTotal = currTotal
    }
    
    func getSubTotalAsString() -> String {
        return "Subtotal: " + String(format: "%.2f" ,self.subTotal!)
    }
}
