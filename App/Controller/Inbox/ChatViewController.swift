//
//  ChatViewController.swift
//  App
//
//  Created by Rahul Guni on 8/20/21.
//

import UIKit
import Parse
import ParseLiveQuery
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    private var myMessages: [ChatRoom] = []
    private var currSender: Sender?
    
    final private var myChatRoomId: String?
    
    var allMessages : [MyMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        myChatRoomId = self.myMessages[0].getChatRoomId()
        setMessagesArray()
        
        //For Live Query
        MyChatRoom.registerSubclass()
        getMessageUpdate()
    }

}

//MARK:- Display Functions
extension ChatViewController {
    
    func setMessages(messages: [ChatRoom]) {
        self.myMessages = messages
    }
    
    func setCurrSender(currSender: Sender) {
        self.currSender = currSender
    }
    
    func setMessagesArray() {
        self.allMessages.removeAll()
        for message in myMessages {
            let newMessage = MyMessage(sender: message.getSender(),
                                       messageId: message.getObjectId(),
                                       sentDate: message.getTime(),
                                       kind: .text(message.getMessage()))
            self.allMessages.append(newMessage)
        }
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func sendMessage(text: String) {
        //First post the message in chatroom then update messages table
        let newMessage = PFObject(className: "ChatRoom")
        newMessage["chatRoomId"] = myChatRoomId!
        newMessage["senderId"] = currSender!.senderId
        newMessage["message"] = text
        newMessage.saveInBackground{(success, error) in
            if(success) {
                self.messageInputBar.inputTextView.text = ""
                let query = PFQuery(className: "Messages")
                query.getObjectInBackground(withId: self.myChatRoomId!) {(message: PFObject?, error: Error?) in
                    if let message = message {
                        message["updatedAt"] = Date()
                        message.saveInBackground()
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
}

//MARK:- , MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currSender!
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return allMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.allMessages.count
    }
    
}

//MARK :- InputBarAccessoryViewDelegate
extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        self.sendMessage(text: inputBar.inputTextView.text!)
    }
    
//    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
//
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
//
//    }
}

//MARK:- Live Query Code
//Subscribe to the current chat room and update messages accordingly.
extension ChatViewController {
    func getMessageUpdate() {
        let myQuery = MyChatRoom.query()!.whereKey("chatRoomId", equalTo: self.myChatRoomId!) as! PFQuery<MyChatRoom>
        
        let subscription: Subscription<MyChatRoom> = Client.shared.subscribe(myQuery)
        subscription.handle(Event.created) { query, object in
            let newMessage = ChatRoom(objectId: object.objectId!,
                                      chatRoomId: self.myChatRoomId! ,
                                      message: object.value(forKey: "message") as! String,
                                      senderId: object.value(forKey: "senderId") as! String,
                                      date: Date())
            self.myMessages.append(newMessage)
            self.setMessagesArray()
        }
    }
}

