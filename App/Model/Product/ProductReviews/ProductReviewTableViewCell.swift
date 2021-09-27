//
//  ProductReviewTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/11/21.
//

import UIKit
import Parse

/**/
/*
class ProductReviewTableViewCell
 
DESCRIPTION
        This class is a UITableViewCell class that makes up the cells for Reviews Table view in ProductReviewViewController.
 
AUTHOR
        Rahul Guni
 
DATE
        09/11/2021
 
*/
/**/

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
    
    /**/
    /*
    func setParameters(productReviw: ProductReview)

    NAME

            setParameters - Sets the parameter for Review Table View Cell.

    SYNOPSIS

            setParameters(productReviw: ProductReview)
                productReview      --> A ProductReview object to fill in the labels with correct data.

    DESCRIPTION

            This function takes an object from the ProductReview model and fills in the labels according to the data.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    func setParameters(productReviw: ProductReview) {
        self.productRating.text = productReviw.getRatingAsString()
        self.content.text = productReviw.getContent()
        self.title.text = productReviw.getTitle()
        getReviewUser(userId: productReviw.getUserId())
    }
    /*func setParameters(productReviw: ProductReview)*/

    /**/
    /*
    func getReviewUser(userId: String)

    NAME

            getReviewUser - Sets the label for the user who had written the review.

    SYNOPSIS

            getReviewUser(userId: String)
                userId    --> userId string to query the user database

    DESCRIPTION

            This function takes the userId and fills the reviewer's name label.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    func getReviewUser(userId: String) {
        let query = PFQuery(className: ShopIO.User().tableName)
        query.whereKey(ShopIO.User().objectId, equalTo: userId)
        query.getFirstObjectInBackground{(user, error) in
            if let user = user {
                let currUser = User(userID: user)
                self.userName.text = currUser.getName()
            }
        }
    }
    /*func getReviewUser(userId: String)*/
}
