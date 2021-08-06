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
    
    init(){
        self.objectId = currentUser?.objectId!
        self.email = currentUser?.value(forKey: "email") as? String
        self.phone = currentUser?.value(forKey: "phone") as? Int
        self.fName = currentUser?.value(forKey: "fName") as? String
        self.lName = currentUser?.value(forKey: "lName") as? String
    }
        
}
