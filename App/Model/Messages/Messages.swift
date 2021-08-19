//
//  Messages.swift
//  App
//
//  Created by Rahul Guni on 8/17/21.
//

import Foundation

import Parse

class Messages: PFObject, PFSubclassing {
    @NSManaged var senderId: String?
    @NSManaged var receiverId: String?
    @NSManaged var content: String?
    @NSManaged var productId: String?
    @NSManaged var shopId: String?

    //Returns the Parse database table where messages are stored
    class func parseClassName() -> String {
        return "Messages"
    }
}
