//
//  AccountTableOptions.swift
//  App
//
//  Created by Rahul Guni on 4/26/21.
//

import Foundation

struct AccountTableOptions {
    let headers = [
        "", "Personal Info", "Settings", "ShopIO", ""
    ]
    
    let cells = [
        ["Sign In"],
        ["My Address", "Payment Methods", "Order History"],
        ["Privacy", "Security", "Edit Profile"],
        ["About Us", "Contact Us", "Privacy Policy"],
        ["Sign Out"]
    ]
}
