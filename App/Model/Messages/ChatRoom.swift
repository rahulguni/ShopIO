//
//  ChatRoom.swift
//  App
//
//  Created by Rahul Guni on 8/19/21.
//

import Foundation

class ChatRoom {
    private var chatRoomId: String
    private var message: String
    private var senderId: String
    private var updateTime: Date
    
    init(chatRoomId: String, message: String, senderId: String, date: Date) {
        self.chatRoomId = chatRoomId
        self.message = message
        self.senderId = senderId
        self.updateTime = date
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
}
