//
//  User.swift
//  App
//
//  Created by Rahul Guni on 7/14/21.
//

import Foundation
import UIKit
import Parse

struct User {
    
    private var objectId: String?
    private var email: String?
    private var phone: Int?
    private var fName: String?
    private var lName: String?
    
    init(userID currUser: PFObject){
        self.objectId = currUser.objectId
        self.email = currUser.value(forKey: "email") as? String
        self.phone = currUser.value(forKey: "phone") as? Int
        self.fName = currUser.value(forKey: "fName") as? String
        self.lName = currUser.value(forKey: "lName") as? String
    }
    
    func getObjectId() -> String {
       return self.objectId!
    }
    
    func getFname() -> String {
        return self.fName!
    }
    
    func getLname() -> String {
        return self.lName!
    }
    
    func getName() -> String {
        return getFname() + " " + getLname()
    }
    
    func getPhone() -> Int {
        return self.phone!
    }
    
    func getPhoneAsString() -> String {
        return String(getPhone())
    }
    
    func getEmail() -> String {
        return self.email!
    }
        
}
