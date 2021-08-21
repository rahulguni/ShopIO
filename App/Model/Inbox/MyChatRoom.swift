//
//  MyChatRoom.swift
//  App
//
//  Created by Rahul Guni on 8/20/21.
//

import Foundation
import Parse

class MyChatRoom: PFObject, PFSubclassing {
    @NSManaged var senderId: String?
    @NSManaged var content: String?
    @NSManaged var chatRoomId: String?

    //Returns the Parse database table where messages are stored
    class func parseClassName() -> String {
        return "ChatRoom"
    }
}
