//
//  ProductReviewTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/11/21.
//

import UIKit
import Parse

class ProductReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var productRating: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setParameters(productReviw: ProductReview) {
        self.productRating.text = productReviw.getRatingAsString()
        self.content.text = productReviw.getContent()
        self.title.text = productReviw.getTitle()
        getReviewUser(userId: productReviw.getUserId())
    }

    func getReviewUser(userId: String) {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: userId)
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                let currUser = User(userID: user)
                self.userName.text = currUser.getName()
            }
        }
    }
}
