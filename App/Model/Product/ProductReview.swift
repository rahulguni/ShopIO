//
//  ProductReview.swift
//  App
//
//  Created by Rahul Guni on 9/10/21.
//

import Foundation
import Parse

class ProductReview {
    private var objectId: String?
    private var parentId: String?
    private var productId: String?
    private var title: String?
    private var content: String?
    private var rating: Int?
    
    init(reviewObject: PFObject) {
        self.objectId = reviewObject.objectId!
        self.parentId = reviewObject["parentId"] as? String
        self.productId = reviewObject["productId"] as? String
        self.title = reviewObject["title"] as? String
        self.content = reviewObject["content"] as? String
        self.rating = reviewObject["rating"] as? Int
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getParentId() -> String {
        return self.parentId!
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
}
