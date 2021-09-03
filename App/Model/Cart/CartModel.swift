//
//  CartModel.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import Foundation

class Cart {
    private final var userId = currentUser!.objectId!
    private var sessionId: String = currentUser!.sessionToken!
    private var subTotal: Double?
    private var itemDiscount: Double?
    private var tax: Double?
    private var shipping: Double?
    private var total: Double?
    private var addressId: String?
    
    init(cartItems: [CartItem]){
        var currTotal = 0.0
        var currDiscount = 0.0
        for item in cartItems {
            currTotal += (item.price!) * Double(item.quantity!)
            currDiscount += (item.discount!) * Double(item.quantity!)
        }
        self.total = currTotal
        self.itemDiscount = currDiscount
        self.tax = (0.05 * self.total!)
        self.subTotal = self.total! + self.tax!
    }
    
    func getTotalAsString() -> String {
        return "Total: $" + String(format: "%.2f" ,self.total!) + " + tax"
    }
    
    func getTotal() -> Double {
        return (self.total! * 100).rounded() / 100
     }
    
    func setAddresId(addressId: String) {
        self.addressId = addressId
    }

    
    func getSubTotal() -> Double {
        return (self.subTotal! * 100).rounded() / 100
    }
    
    func getSubTotalAsString() -> String {
        return "SubTotal: $" + String(format: "%.2f" ,self.subTotal!)
    }
    
    func getTax() -> Double {
        return (self.tax! * 100).rounded() / 100
    }
    
    func getTaxAsString() -> String {
        return "Tax: $" + String(format: "%.2f" ,self.tax!)
    }
    
    func getAddressId() -> String {
        return self.addressId!
    }
    
    func getItemDiscount() -> Double {
        return (self.itemDiscount! * 100).rounded() / 100
    }
    
    func getSessionId() -> String {
        return self.sessionId
    }
 
}
