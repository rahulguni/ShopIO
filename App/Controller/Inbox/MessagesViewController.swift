//
//  MessagesViewController.swift
//  App
//
//  Created by Rahul Guni on 8/19/21.
//

import UIKit
import Parse

class MessagesViewController: UIViewController{
    
    @IBOutlet weak var messagesTable: UITableView!
    
    private var myMessages: [MessageModel] = []
    private var chatRooms: [ChatRoom] = []
    private var forShop: Bool = false
    private var senderImage: UIImage?
    private var currSender: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //messagesTable.isHidden = true
        messagesTable.delegate = self
        messagesTable.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyMessage") {
            let destination = segue.destination as! MyMessageTableViewController
            destination.setMessages(messages: self.chatRooms)
            destination.setImage(sender: senderImage!)
            destination.setCurrSender(currSender: self.currSender!)
        }
    }
}

//MARK:- Display Functions
extension MessagesViewController {
    
    func setForShop(bool: Bool) {
        self.forShop = bool
    }
    
    func setMessages(messages: [MessageModel]) {
        self.myMessages = messages
    }
    
    func setSender(currSender: String) {
        self.currSender = currSender
    }
    
}

//MARK:- UITableViewDelegate
extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatRooms.removeAll()
        let chatRoom: String = myMessages[indexPath.row].getChatRoomId()
        self.senderImage = myMessages[indexPath.row].getSenderImage()
        let query = PFQuery(className: "ChatRoom")
        query.whereKey("chatRoomId", equalTo: chatRoom)
        query.order(byAscending: "updatedAt")
        query.findObjectsInBackground{(messages: [PFObject]?, error: Error?) in
            if let messages = messages {
                for message in messages {
                    let senderId: String = message.value(forKey: "senderId") as! String
                    let currMessage: String = message.value(forKey: "message") as! String
                    let date: Date = message.value(forKey: "updatedAt") as! Date
                    let newChatRoom = ChatRoom(chatRoomId: chatRoom, message: currMessage, senderId: senderId, date: date)
                    self.chatRooms.append(newChatRoom)
                    
                }
                self.performSegue(withIdentifier: "goToMyMessage", sender: self)
            }
        }
    }
}

//MARK:- UITableViewDataSource
extension MessagesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMessageCell", for: indexPath) as! MessageTableViewCell
        cell.setParameters(forShop: forShop, message: myMessages[indexPath.row])
        return cell
    }
}






