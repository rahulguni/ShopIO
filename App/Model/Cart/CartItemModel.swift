//
//  CartItemModel.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import Foundation
import RealmSwift

class CartItem: Object {
    @Persisted var userId: String?
    @Persisted var productId: String?
    @Persisted var price: Double?
    @Persisted var discount: Double?
    @Persisted var quantity: Int?
    @Persisted var content: String?
}
