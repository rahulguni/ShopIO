import Foundation
import Parse

/**/
/*
class Request

DESCRIPTION
        This class is the model to render data from Request database. This class also has all the required setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        08/07/2021
*/
/**/

struct Request {
    private var objectId: String? // objectId of the request
    private var shopId: String? // shopId of the requested Product, foreign key to objectId of shop database
    private var userId: String? // userId of the requested Product, foreign key to objectId of user database
    private var productId: String? //productId of the requested Product, foreign key to objectId of product
    private var fulfilled: Bool? // boolean variable to record whether or not the request is fulfilled.
    
    //Constructor
    init(request myRequest: PFObject) {
        self.objectId = myRequest.objectId
        self.shopId = myRequest.value(forKey: "shopId") as? String
        self.userId = myRequest.value(forKey: "userId") as? String
        self.productId = myRequest.value(forKey: "productId") as? String
        self.fulfilled = myRequest.value(forKey: "fulfilled") as? Bool
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getShopId() -> String {
        return self.shopId!
    }
    
    func getUserId() -> String {
        return self.userId!
    }
    
    func getProductId() -> String {
        return self.productId!
    }
    
    func getFulfilled() -> Bool {
        return self.fulfilled!
    }
}
