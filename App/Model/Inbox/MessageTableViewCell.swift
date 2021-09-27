import UIKit
import Parse

/**/
/*
class MessageTableViewCell

DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Messages Table in MessagesViewController.
 
AUTHOR
        Rahul Guni
 
DATE
        08/18/2021
 
*/
/**/

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var dateField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**/
    /*
    func setParameters(forShop bool: Bool, message currMessage: MessageModel)

    NAME

            setParameters - Sets the parameter for Message Table View Cell.

    SYNOPSIS

            setParameters(forShop bool: Bool, message currMessage: MessageModel)
                forShop             --> A boolean variable to determine if the message cell is for shop inbox or user inbox
                message             --> Message object from database to name the message sender as well as get into chatroom
                                        from the MessageModel objectId.

    DESCRIPTION

            This function takes a boolean variable and a MessageModel object to render the right data to tableview cell. First,
            the Message table in database is searched by the MessageModel model's objectId variable to render the message sender.
            Then, using the same objectId, the chatroom table is searched to render the most recent message between the two parties.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/18/2021

    */
    /**/
    
    func setParameters(forShop bool: Bool, message currMessage: MessageModel) {
        let query: PFQuery<PFObject>
        if(!bool) {
            //look for shops
            query = PFQuery(className: ShopIO.Shop().tableName)
            query.whereKey(ShopIO.Shop().objectId, equalTo: currMessage.getReceiverId())
        }
        else{
            //look for users
            query = PFQuery(className: ShopIO.User().tableName)
            query.whereKey(ShopIO.User().objectId, equalTo: currMessage.getSenderId())
        }
        
        query.getFirstObjectInBackground{(object: PFObject?, error: Error?) in
            if let object = object {
                let displayImage: PFFileObject?
                if(bool){
                    let newUser = User(userID: object)
                    currMessage.setSenderName(name: newUser.getName())
                    displayImage = newUser.getImage()
                }
                else {
                    let newShop = Shop(shop: object)
                    currMessage.setSenderName(name: newShop.getShopTitle())
                    displayImage = newShop.getShopImage()
                }
                //set sender Name
                self.senderName.text = currMessage.getSenderName()
                
                displayImage?.getDataInBackground{(image, error) in
                    if let image = image {
                        self.senderImage.image = UIImage(data: image)
                        currMessage.setSenderImage(image: UIImage(data: image)!)
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
                
                //set sender most recent Message to display (From chatRoom database)
                let chatRoomQuery = PFQuery(className: ShopIO.ChatRoom().tableName)
                chatRoomQuery.whereKey(ShopIO.ChatRoom().chatRoomId, equalTo: currMessage.getChatRoomId())
                chatRoomQuery.order(byDescending: ShopIO.ChatRoom().updatedAt)
                
                chatRoomQuery.getFirstObjectInBackground{(chatRoom, error) in
                    if let chatRoom = chatRoom {
                        let id: String = chatRoom.objectId!
                        let message: String = chatRoom.value(forKey: ShopIO.ChatRoom().message) as! String
                        let senderId: String = chatRoom.value(forKey: ShopIO.ChatRoom().senderId) as! String
                        let updateTime: Date = chatRoom.value(forKey: ShopIO.ChatRoom().updatedAt) as! Date
                        
                        let newRoom = ChatRoom(objectId: chatRoom.objectId!, chatRoomId: id, message: message, senderId: senderId, date: updateTime)
                        self.message.text = newRoom.getMessage()
                        self.dateField.text = String(updateTime.debugDescription.prefix(10))
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
    /* func setParameters(forShop bool: Bool, message currMessage: MessageModel) */

}
