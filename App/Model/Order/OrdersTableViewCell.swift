//
//  OrdersTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/3/21.
//

import UIKit
import Parse

class OrdersTableViewCell: UITableViewCell {
    @IBOutlet weak var orderUser: UILabel!
    @IBOutlet weak var orderUserImage: UIImageView!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var deliveryMethod: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(order: Order){
        self.orderTotal.text = "Total: " + String(order.getSubTotal())
        if(order.getPickUp()) {
            self.deliveryMethod.text = "Delivery Method: Pickup"
        }
        else{
            self.deliveryMethod.text = "Delivery Method: Ship"
        }
        getOrderUser(order: order)
    }
    
    func getOrderUser(order: Order){
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: order.getUsertId())
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                let currUser = User(userID: user)
                self.orderUser.text = "By: " + currUser.getName()
                let userImage = currUser.getImage()
                userImage.getDataInBackground{(image, error) in
                    if let image = image {
                        self.orderUserImage.image = UIImage(data: image)
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
