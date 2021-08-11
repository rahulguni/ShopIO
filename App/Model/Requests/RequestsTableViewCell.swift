//
//  RequestsTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/7/21.
//

import UIKit
import Parse

class RequestsTableViewCell: UITableViewCell {
    @IBOutlet weak var requestUser: UILabel!
    @IBOutlet weak var requestProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(request currRequest: Request) {
        let userQuery = PFQuery(className: "_User")
        userQuery.whereKey("objectId", equalTo: currRequest.getUserId())
        userQuery.getFirstObjectInBackground{(user, error) in
            if(user != nil) {
                let name = (user?.value(forKey: "fName") as! String) + " " + (user?.value(forKey: "lName") as! String)
                self.requestUser.text = "From: \(name)"
            }
        }
        let productQuery = PFQuery(className: "Product")
        productQuery.whereKey("objectId", equalTo: currRequest.getProductId())
        productQuery.getFirstObjectInBackground{(product, error) in
            if(product != nil) {
                let product = product?.value(forKey: "title") as? String
                self.requestProduct.text = "Product: \(product!)"
            }
        }
    }
    

}
