//
//  Address.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//

import Foundation
import Parse

struct Address {
    private var objectId: String?
    private var userId: String?
    private var line_1: String?
    private var line_2: String?
    private var city: String?
    private var state: String?
    private var country: String = "USA"
    private var zip: String?
    private var phone: Int?
    
    init(address addressObject: PFObject?){
        self.objectId = addressObject!.objectId
        self.userId = addressObject!["userId"] as? String
        self.line_1 = addressObject!["line_1"] as? String
        self.line_2 = addressObject!["line_2"] as? String
        self.city = addressObject!["city"] as? String
        self.state = addressObject!["state"] as? String
        self.zip = addressObject!["zip"] as? String
        self.phone = addressObject!["phone"] as? Int
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getLine1() -> String? {
        return self.line_1!
    }
    
    func getLine2() -> String? {
        return self.line_2!
    }
    
    func getCity() -> String? {
        return self.city
    }
    
    func getState() -> String? {
        return self.state
    }
    
    func getCountry() -> String? {
        return self.country
    }
    
    func getZip() -> String? {
        return self.zip
    }
    
    func getPhone() -> Int? {
        return self.phone
    }
    
}
