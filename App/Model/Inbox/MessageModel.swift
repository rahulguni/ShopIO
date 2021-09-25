import Foundation
import Parse

/**/
/*
class MessageTableViewCell

DESCRIPTION
        This class is the model to render data from Message database. This class also has all the required setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        08/17/2021
*/
/**/

class MessageModel {
    private var senderId: String?       // objectId of sender (which is always the user), foreign key to objectId of user.
    private var receiverId: String?     // objectId of receiver (which is always the shop), foreign key to obejctId of shop
    private var chatRoomId: String?     // objectId of the MessageModel itself, used in ChatRoom to render correct chats.
    private var senderName: String?     // Full name of sender (Queries done in the controller because this can be both shop or user)
    private var senderImage: UIImage?   // Image of sender (Queries done in the controller because this can be both shop or user)
    
    // Constructor
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
