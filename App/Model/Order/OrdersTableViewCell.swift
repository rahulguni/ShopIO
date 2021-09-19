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
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(order: Order, forUser: Bool){
        self.orderTotal.text = "Total: " + String(order.getSubTotal())
        self.orderDate.text = "Date: \(order.getOrderDate())"
        setStatus(order: order)
        if(forUser) {
            getOrderShop(order: order)
        }
        else{
            getOrderUser(order: order)
        }
    }
    
    func setStatus(order: Order) {
        if(order.getFulfilled() == false) {
            self.orderStatus.text = "Pending"
            self.orderStatus.isHidden = false
        }
        else {
            let query = PFQuery(className: "Order_Item")
            query.whereKey("orderId", equalTo: order.getObjectId())
            query.findObjectsInBackground{(products, error) in
                if let products = products {
                    if(products.count > 0) {
                        self.orderStatus.text = "Fulfilled"
                    }
                    else {
                        self.orderStatus.text = "Deleted"
                    }
                    self.orderStatus.isHidden = false
                }
                else {
                    self.orderStatus.isHidden = true
                }
            }
        }
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
    
    func getOrderShop(order: Order) {
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: order.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                let currShop = Shop(shop: shop)
                self.orderUser.text = currShop.getShopTitle()
                let shopImage = currShop.getShopImage()
                shopImage.getDataInBackground{(image, error) in
                    if let image = image {
                        self.orderUserImage.image = UIImage(data: image)
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
            }
            else{
                print(error.debugDescription)
            }
        }
    }

}