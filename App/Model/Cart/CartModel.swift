//
//  CartModel.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import Foundation
import RealmSwift

class Cart : Object {
    @Persisted var userId: String?
    @Persisted var sessionId: String?
    @Persisted var subTotal: Double?
    @Persisted var itemDiscount: Double?
    @Persisted var tax: Double?
    @Persisted var shipping: Double?
    @Persisted var total: Double?
    @Persisted var addressId: String?
}
