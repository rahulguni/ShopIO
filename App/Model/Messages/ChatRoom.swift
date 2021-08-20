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
    
    init(chatRoomId: String, message: String, senderId: String) {
        self.chatRoomId = chatRoomId
        self.message = message
        self.senderId = senderId
    }
    
    func getMessage() -> String {
        return self.message
    }
    
    func getChatRoomId() -> String {
        return self.chatRoomId
    }
}
