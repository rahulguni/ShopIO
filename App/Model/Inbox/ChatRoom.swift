//
//  ChatRoom.swift
//  App
//
//  Created by Rahul Guni on 8/19/21.
//

import Foundation

class ChatRoom {
    private var objectId: String
    private var chatRoomId: String
    private var message: String
    private var senderId: String
    private var updateTime: Date
    private var sender: Sender
    
    init(objectId: String, chatRoomId: String, message: String, senderId: String, date: Date) {
        self.chatRoomId = chatRoomId
        self.message = message
        self.senderId = senderId
        self.updateTime = date
        self.objectId = objectId
        self.sender = Sender(senderId: senderId, displayName: "")
    }
    
    func getMessage() -> String {
        return self.message
    }
    
    func getChatRoomId() -> String {
        return self.chatRoomId
    }
    
    func getTime() -> Date {
        return self.updateTime
    }
    
    func getSenderId() -> String {
        return self.senderId
    }
    
    func getObjectId() -> String {
        return self.objectId
    }
    
    func getSender() -> Sender {
        return self.sender
    }
}
