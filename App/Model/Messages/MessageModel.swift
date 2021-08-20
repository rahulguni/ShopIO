//
//  MessageModel.swift
//  App
//
//  Created by Rahul Guni on 8/17/21.
//

import Foundation
import Parse

class MessageModel {
    private var senderId: String?
    private var receiverId: String?
    private var chatRoomId: String?
    private var senderName: String?
    private var senderImage: UIImage?
    
    init(sender: String, receiver: String, chatRoomId: String) {
        self.senderId = sender
        self.receiverId = receiver
        self.chatRoomId = chatRoomId
    }
    
    func getSenderId() -> String {
        return self.senderId!
    }
    
    func getReceiverId() -> String {
        return self.receiverId!
    }
    
    func getChatRoomId() -> String {
        return self.chatRoomId!
    }
    
    func setSenderName(name: String) {
        self.senderName = name
    }
    
    func setSenderImage(image: UIImage) {
        self.senderImage = image
    }
    
    func getSenderName() -> String {
        return self.senderName!
    }
    
    func getSenderImage() -> UIImage {
        return self.senderImage!
    }
}
