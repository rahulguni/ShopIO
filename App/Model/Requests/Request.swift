//
//  Request.swift
//  App
//
//  Created by Rahul Guni on 8/7/21.
//

import Foundation
import Parse

struct Request {
    private var objectId: String?
    private var shopId: String?
    private var userId: String?
    private var productId: String?
    private var fulfilled: Bool?
    
    init(request myRequest: PFObject) {
        self.objectId = myRequest.objectId
        self.shopId = myRequest.value(forKey: "shopId") as? String
        self.userId = myRequest.value(forKey: "userId") as? String
        self.productId = myRequest.value(forKey: "productId") as? String
        self.fulfilled = myRequest.value(forKey: "fulfilled") as? Bool
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getShopId() -> String {
        return self.shopId!
    }
    
    func getUserId() -> String {
        return self.userId!
    }
    
    func getProductId() -> String {
        return self.productId!
    }
    
    func getFulfilled() -> Bool {
        return self.fulfilled!
    }
}
