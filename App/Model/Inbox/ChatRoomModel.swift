//
//  ChatRoomModel.swift
//  App
//
//  Created by Rahul Guni on 8/20/21.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct MyMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
