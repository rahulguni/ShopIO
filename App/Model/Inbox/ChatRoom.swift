import Foundation

/**/
/*
class ChatRoom

DESCRIPTION
        This class is the model to render data from ChatRoom database. This class has private variables chatRoomId, message, senderId, updateTime and sender. Sender is a MessageKit class that helps render the correct sender and receiever in the MessageTableView. This class also has all the setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        08/19/2021
*/
/**/

class ChatRoom {
    private var objectId: String // objectId of the chatRoom
    private var chatRoomId: String //objectId of Message Model
    private var message: String //data sent between the two parties
    private var senderId: String //record objectId of sender
    private var updateTime: Date //time to record the most recent message
    private var sender: Sender //to record senderName and senderId for MessageKit.
    
    // Constructor
    init(objectId: String, chatRoomId: String, message: String, senderId: String, date: Date) {
        self.chatRoomId = chatRoomId
        self.message = message
        self.senderId = senderId
        self.updateTime = date
        self.objectId = objectId
        self.sender = Sender(senderId: senderId, displayName: "")
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
    
    func getObjectId() -> String {
        return self.objectId
    }
    
    func getSender() -> Sender {
        return self.sender
    }
}
