//
//  MessagesViewController.swift
//  App
//
//  Created by Rahul Guni on 8/19/21.
//

import UIKit
import Parse
import ParseLiveQuery

class MyMessagesViewController: UIViewController{
    
    @IBOutlet weak var messagesTable: UITableView!
    
    private var myMessages: [MessageModel] = []
    private var chatRooms: [ChatRoom] = []
    private var forShop: Bool = false
    private var senderImage: UIImage?
    private var currSender: Sender?
    
    private var titleForChatRoom: String?
    private var currChatRoomId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //messagesTable.isHidden = true
        messagesTable.delegate = self
        messagesTable.dataSource = self
        Messages.registerSubclass()
        getMessageUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToChatView") {
            let destination = segue.destination as! ChatViewController
            destination.setMessages(messages: self.chatRooms)
            destination.setCurrSender(currSender: self.currSender!)
            destination.title = self.titleForChatRoom!
            destination.setChatRoomId(chatroomId: self.currChatRoomId!)
        }
    }
}

//MARK:- Display Functions
extension MyMessagesViewController {
    
    func setForShop(bool: Bool) {
        self.forShop = bool
    }
    
    func setMessages(messages: [MessageModel]) {
        self.myMessages = messages
    }
    
    func setSender(currSender: Sender) {
        self.currSender = currSender
    }
    
}

//MARK:- UITableViewDelegate
extension MyMessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatRooms.removeAll()
        let chatRoom: String = myMessages[indexPath.row].getChatRoomId()
        self.titleForChatRoom = myMessages[indexPath.row].getSenderName()
        self.currChatRoomId = myMessages[indexPath.row].getChatRoomId()
        let query = PFQuery(className: "ChatRoom")
        query.whereKey("chatRoomId", equalTo: chatRoom)
        query.order(byAscending: "updatedAt")
        query.findObjectsInBackground{(messages: [PFObject]?, error: Error?) in
            if let messages = messages {
                for message in messages {
                    let senderId: String = message.value(forKey: "senderId") as! String
                    let currMessage: String = message.value(forKey: "message") as! String
                    let date: Date = message.value(forKey: "updatedAt") as! Date
                    let newChatRoom = ChatRoom(objectId: message.objectId! ,chatRoomId: chatRoom, message: currMessage, senderId: senderId, date: date)
                    self.chatRooms.append(newChatRoom)
                    
                }
                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "goToChatView", sender: self)
            }
        }
    }
}

//MARK:- UITableViewDataSource
extension MyMessagesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMessageCell", for: indexPath) as! MessageTableViewCell
        cell.setParameters(forShop: forShop, message: myMessages[indexPath.row])
        return cell
    }
}

//MARK:- LiveQuery Code
extension MyMessagesViewController {
    func getMessageUpdate() {
        var query: PFQuery<Messages>
        if(forShop) {
            query = Messages.query()!.whereKey("receiverId", equalTo: currSender!.senderId) as! PFQuery<Messages>
        }
        else{
            query = Messages.query()!.whereKey("senderId", equalTo: currSender!.senderId) as! PFQuery<Messages>
        }
        let subscription: Subscription<Messages> = Client.shared.subscribe(query)
        subscription.handle(Event.updated) { query, object in
            DispatchQueue.main.async {
                //move the most recent message to top if message already exists, else add new
                var arrayIndex = 0
                for message in self.myMessages {
                    if(message.getChatRoomId() == object.objectId!) {
                        self.myMessages = rearrange(array: self.myMessages, fromIndex: arrayIndex, toIndex: 0)
                    }
                    else {
                        arrayIndex += 1
                    }
                }
                self.messagesTable.reloadData()
            }
        }
        subscription.handle(Event.created) { query, object in
            let newMessage = MessageModel(sender: object.value(forKey: "senderId") as! String,
                                          receiver: object.value(forKey: "receiverId") as! String,
                                          chatRoomId: object.objectId!)
            self.myMessages.append(newMessage)
            DispatchQueue.main.async {
                //move the new message to top
                self.myMessages = rearrange(array: self.myMessages, fromIndex: self.myMessages.count - 1, toIndex: 0)
                self.messagesTable.reloadData()
            }
        }
    }
}
