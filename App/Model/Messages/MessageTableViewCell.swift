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
            query = PFQuery(className: "Shop")
        }
        else{
            query = PFQuery(className: "_User")
        }
        query.whereKey("objectId", equalTo: currMessage.getSenderId())
        query.getFirstObjectInBackground{(object: PFObject?, error: Error?) in
            if let object = object {
                if(self.forShop!){
                    let newUser = User(userID: object)
                    currMessage.setSenderName(name: newUser.getName())
                }
                else {
                    let newShop = Shop(shop: object)
                    currMessage.setSenderName(name: newShop.getShopTitle())
                }
                self.senderName.text = currMessage.getSenderName()
                self.message.text = currMessage.getMessage()
            }
            else {
                print(error.debugDescription)
            }
        }
    }

}
