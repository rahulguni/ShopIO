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
    private var objectId: String?
    private var userId: String?
    private var productId: String?
    private var title: String?
    private var content: String?
    private var rating: Int?
    
    //constructor
    init(reviewObject: PFObject) {
        self.objectId = reviewObject.objectId!
        self.userId = reviewObject["userId"] as? String
        self.productId = reviewObject["productId"] as? String
        self.title = reviewObject["title"] as? String
        self.content = reviewObject["content"] as? String
        self.rating = reviewObject["rating"] as? Int
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
