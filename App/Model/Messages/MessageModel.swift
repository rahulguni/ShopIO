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
    private var message: String?
    private var senderName: String?
    private var senderImage: UIImage?
    
    init(sender: String, receiver: String, message: String) {
        self.senderId = sender
        self.receiverId = receiver
        self.message = message
    }
    
    func getSenderId() -> String {
        return self.senderId!
    }
    
    func getReceiverId() -> String {
        return self.receiverId!
    }
    
    func getMessage() -> String {
        return self.message!
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
