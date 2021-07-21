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
        self.objectId = nil
        self.email = nil
        self.phone = nil
        self.fName = nil
        self.lName = nil
    }
        
}
