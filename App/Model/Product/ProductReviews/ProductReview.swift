//
//  ProductReview.swift
//  App
//
//  Created by Rahul Guni on 9/10/21.
//

import Foundation
import Parse

/**/
/*
class ProductReview

DESCRIPTION
        This class is the model to render data from Product_Review database. This class also has all the setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        09/10/2021
*/
/**/

class ProductReview {
    private var objectId: String?   // objectId of the product review
    private var userId: String?     //userId of the product reveiwer, foreign key to users table
    private var productId: String?  //productId of the reviewed product, foreign key to Products table
    private var title: String?
    private var content: String?
    private var rating: Int?
    
    //constructor
    init(reviewObject: PFObject) {
        self.objectId = reviewObject.objectId!
        self.userId = reviewObject[ShopIO.Product_Review().userId] as? String
        self.productId = reviewObject[ShopIO.Product_Review().productId] as? String
        self.title = reviewObject[ShopIO.Product_Review().title] as? String
        self.content = reviewObject[ShopIO.Product_Review().content] as? String
        self.rating = reviewObject[ShopIO.Product_Review().rating] as? Int
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getUserId() -> String {
        return self.userId!
    }
    
    func getProductId() -> String {
        return self.productId!
    }
    
    func getTitle() -> String {
        return self.title!
    }
    
    func getContent() -> String {
        return self.content!
    }
    
    func getRating() -> Int {
        return self.rating!
    }
    
    func getRatingAsString() -> String {
        return String((Double(self.rating!) * 100).rounded() / 100)
    }
}
