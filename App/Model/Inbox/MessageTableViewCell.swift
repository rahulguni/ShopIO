//
//  MessageTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/18/21.
//

import UIKit
import Parse

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var message: UILabel!
    
    private var forShop: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(forShop bool: Bool, message currMessage: MessageModel) {
        self.forShop = bool
        let query: PFQuery<PFObject>
        if(forShop == false) {
            //look for shops
            query = PFQuery(className: "Shop")
            query.whereKey("objectId", equalTo: currMessage.getReceiverId())
        }
        else{
            //look for users
            query = PFQuery(className: "_User")
            query.whereKey("objectId", equalTo: currMessage.getSenderId())
        }
        
        query.getFirstObjectInBackground{(object: PFObject?, error: Error?) in
            if let object = object {
                let displayImage: PFFileObject?
                if(self.forShop!){
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
                let chatRoomQuery = PFQuery(className: "ChatRoom")
                chatRoomQuery.whereKey("chatRoomId", equalTo: currMessage.getChatRoomId())
                chatRoomQuery.order(byDescending: "updatedAt")
                
                chatRoomQuery.getFirstObjectInBackground{(chatRoom, error) in
                    if let chatRoom = chatRoom {
                        let id: String = chatRoom.objectId!
                        let message: String = chatRoom.value(forKey: "message") as! String
                        let senderId: String = chatRoom.value(forKey: "senderId") as! String
                        let updateTime: Date = chatRoom.value(forKey: "updatedAt") as! Date
                        
                        let newRoom = ChatRoom(objectId: chatRoom.objectId!, chatRoomId: id, message: message, senderId: senderId, date: updateTime)
                        self.message.text = newRoom.getMessage()
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
