import UIKit
import Parse
import ParseLiveQuery
import MessageKit
import InputBarAccessoryView

/**/
/*
class ChatViewController

DESCRIPTION
        This class is a UIViewController that extends MessagesViewController. This class controls Messages.storyboard's ChatRoom View. Link: https://github.com/MessageKit/MessageKit
AUTHOR
        Rahul Guni
DATE
        08/20/2021
*/
/**/

class ChatViewController: MessagesViewController {
    
    //Controller Parameters
    private var myMessages: [ChatRoom] = []         //All objects from ChatRoom table for current chatRoomId
    private var allMessages : [MyMessage] = []      //MessageKit array to render individual messages.
    private var currSender: Sender?                 // Current Sender
    final private var myChatRoomId: String?         //Current chatRoomId

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        setMessagesArray()
        
        //For Live Query
        MyChatRoom.registerSubclass()
        getMessageUpdate()
    }

}

//MARK:- Display Functions
extension ChatViewController {
    
    //Setter function to fill up myMessages array, passed on from previous view controller (MessagesViewController)
    func setMessages(messages: [ChatRoom]) {
        self.myMessages = messages
    }
    
    //Setter function to set up current Sender, passed on from previous view controller (MessagesViewController)
    func setCurrSender(currSender: Sender) {
        self.currSender = currSender
    }
    
    //Setter function to set up current chatRoomId, passed on from previous view controller (MessagesViewController)
    func setChatRoomId(chatroomId: String) {
        self.myChatRoomId = chatroomId
    }
    
    //Function to transfer data from myMessages array to MessageKit's prototype array.
    private func setMessagesArray() {
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
    
    /**/
    /*
    private func sendMessage(text: String)

    NAME

            sendMessage - Uploads message to respective chatRoom and updates the Messages Table.
     
    SYNOPSIS
           
            sendMessage(text: String)
                text        --> Message string to be sent.

    DESCRIPTION

            This function takes in the message string and uploads a new message in the ChatRoom table with appropriate data. After this is completed, it updates the updatedAt date in Message table for the current chatRoom.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/20/2021

    */
    /**/
    
    private func sendMessage(text: String) {
        //First post the message in chatroom then update messages table
        let newMessage = PFObject(className: ShopIO.ChatRoom().tableName)
        newMessage[ShopIO.ChatRoom().chatRoomId] = myChatRoomId!
        newMessage[ShopIO.ChatRoom().senderId] = currSender!.senderId
        newMessage[ShopIO.ChatRoom().message] = text
        newMessage.saveInBackground{(success, error) in
            if(success) {
                self.messageInputBar.inputTextView.text = ""
                //Update the updatedAt date in MessagesTable
                let query = PFQuery(className: ShopIO.Messages().tableName)
                query.getObjectInBackground(withId: self.myChatRoomId!) {(message: PFObject?, error: Error?) in
                    if let message = message {
                        message[ShopIO.Messages().updatedAt] = Date()
                        message.saveInBackground()
                    }
                    else{
                        let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to send message.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /*private func sendMessage(text: String)*/
}

//MARK:- , MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    /* MessageKit functions */
    
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
extension ChatViewController {
    
    /**/
    /*
    private func getMessageUpdate

    NAME

            getMessageUpdate -  LiveQuery function to update the table view cells

    DESCRIPTION

            This function subscribes to the ChatRoom Table from LiveQuery feature of parse and updates the tableview cells if a message is uploaded in the subscribed table.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/20/2021

    */
    /**/
    
    func getMessageUpdate() {
        let myQuery = MyChatRoom.query()!.whereKey(ShopIO.ChatRoom().chatRoomId, equalTo: self.myChatRoomId!) as! PFQuery<MyChatRoom>
        
        let subscription: Subscription<MyChatRoom> = Client.shared.subscribe(myQuery)
        subscription.handle(Event.created) { query, object in
            let newMessage = ChatRoom(objectId: object.objectId!,
                                      chatRoomId: self.myChatRoomId! ,
                                      message: object.value(forKey: ShopIO.ChatRoom().message) as! String,
                                      senderId: object.value(forKey: ShopIO.ChatRoom().senderId) as! String,
                                      date: Date())
            self.myMessages.append(newMessage)
            self.setMessagesArray()
        }
    }
    /* func getMessageUpdate() */
}

