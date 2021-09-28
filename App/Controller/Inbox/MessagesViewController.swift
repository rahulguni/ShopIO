import UIKit
import Parse
import ParseLiveQuery

/**/
/*
class MyMessagesViewController

DESCRIPTION
        This class is a UIViewController that controls Messages.storyboard's Messages View.
 
AUTHOR
        Rahul Guni
 
DATE
        08/19/2021
 
*/
/**/

class MyMessagesViewController: UIViewController{
    
    //IBOutlet elements
    @IBOutlet weak var messagesTable: UITableView!
    
    //Controller Parameters
    private var myMessages: [MessageModel] = [] //All Messages
    private var chatRooms: [ChatRoom] = []      //All Chats for current Messages
    private var forShop: Bool = false           //Determines if the messageView is for shop or user
    private var senderImage: UIImage?           //Image of the other party in chat view
    private var currSender: Sender?             //Current Sender (shop or user determined by forShop: Bool
    
    private var titleForChatRoom: String?       //Name of sender for ChatViewController title
    private var currChatRoomId: String?         //objectId of current Message Object
    
    //Declare a label to render in case there is no message.
    private let noMessagesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //messagesTable.isHidden = true
        messagesTable.delegate = self
        messagesTable.dataSource = self
        Messages.registerSubclass()
        getMessageUpdate()
        checkMessageExists()
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
    
    //Setter function to set up forShop variable, passed on from previous view controller (InboxViewController)
    func setForShop(bool: Bool) {
        self.forShop = bool
    }
    
    //Setter function to set up current Messages, passed on from previous view controller (InboxViewController)
    func setMessages(messages: [MessageModel]) {
        self.myMessages = messages
    }
    
    //Setter function to set up current Sender, passed on from previous view controller (InboxViewController)
    func setSender(currSender: Sender) {
        self.currSender = currSender
    }
    
    //Function to render noMessageLabel if messages do not exist.
    private func checkMessageExists() {
        if(self.myMessages.isEmpty){
            self.messagesTable.isHidden = true
            self.view.backgroundColor = UIColor.lightGray
            noMessagesLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            noMessagesLabel.textAlignment = .center
            noMessagesLabel.text = "No Messages Found."
            self.view.addSubview(noMessagesLabel)
        }
        else {
            self.view.backgroundColor = UIColor.white
            self.messagesTable.isHidden = false
            noMessagesLabel.removeFromSuperview()
        }
    }
    
}

//MARK:- UITableViewDelegate
extension MyMessagesViewController: UITableViewDelegate {
    
    /**/
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

    NAME

           tableView - Action for TableView Cell click.

    DESCRIPTION

            This function records the current Message object's chatRoomId, fetches all chats from the chatroom
            and appends it to chatRoom array before it performs segue to ChatViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/19/2021

    */
    /**/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatRooms.removeAll()
        let chatRoom: String = myMessages[indexPath.row].getChatRoomId()
        self.titleForChatRoom = myMessages[indexPath.row].getSenderName()
        self.currChatRoomId = myMessages[indexPath.row].getChatRoomId()
        let query = PFQuery(className: ShopIO.ChatRoom().tableName)
        query.whereKey(ShopIO.ChatRoom().chatRoomId, equalTo: chatRoom)
        query.order(byAscending: ShopIO.ChatRoom().updatedAt)
        query.findObjectsInBackground{(messages: [PFObject]?, error: Error?) in
            if let messages = messages {
                for message in messages {
                    let senderId: String = message.value(forKey: ShopIO.ChatRoom().senderId) as! String
                    let currMessage: String = message.value(forKey: ShopIO.ChatRoom().message) as! String
                    let date: Date = message.value(forKey: ShopIO.ChatRoom().updatedAt) as! Date
                    let newChatRoom = ChatRoom(objectId: message.objectId! ,chatRoomId: chatRoom, message: currMessage, senderId: senderId, date: date)
                    self.chatRooms.append(newChatRoom)
                    
                }
                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "goToChatView", sender: self)
            }
        }
    }
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)*/
}

//MARK:- UITableViewDataSource
extension MyMessagesViewController: UITableViewDataSource{
    
    //function to render the number of Message Objects in TableView Cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMessages.count
    }
    
    //function to populate the tableView Cells, from MessageTableViewCell.swift
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMessageCell", for: indexPath) as! MessageTableViewCell
        cell.setParameters(forShop: forShop, message: myMessages[indexPath.row])
        return cell
    }
}

//MARK:- LiveQuery Code
extension MyMessagesViewController {
    
    /**/
    /*
    private func getMessageUpdate

    NAME

            getMessageUpdate -  LiveQuery function to update the table view cells

    DESCRIPTION

            This function subscribes to the Message Table from LiveQuery feature of parse and updates
            the tableview cells if a message is uploaded/edited in the subscribed table.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/19/2021

    */
    /**/
    
    private func getMessageUpdate() {
        var query: PFQuery<Messages>
        if(forShop) {
            query = Messages.query()!.whereKey(ShopIO.Messages().receiverId, equalTo: currSender!.senderId) as! PFQuery<Messages>
        }
        else{
            query = Messages.query()!.whereKey(ShopIO.Messages().senderId, equalTo: currSender!.senderId) as! PFQuery<Messages>
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
            let newMessage = MessageModel(sender: object.value(forKey: ShopIO.Messages().senderId) as! String,
                                          receiver: object.value(forKey: ShopIO.Messages().receiverId) as! String,
                                          chatRoomId: object.objectId!)
            self.myMessages.append(newMessage)
            DispatchQueue.main.async {
                //move the new message to top
                self.myMessages = rearrange(array: self.myMessages, fromIndex: self.myMessages.count - 1, toIndex: 0)
                self.messagesTable.reloadData()
            }
        }
    }
    /* private func getMessageUpdate() */
}
