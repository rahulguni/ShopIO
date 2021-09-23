import Foundation
import UIKit
import Parse

/**/
/*
class User

DESCRIPTION
        This class is the model to render data from User database. This class also has all the required setter and getter properies for the parameters.
AUTHOR
        Rahul Guni
DATE
        07/14/2021
*/
/**/

struct User {
    
    private var objectId: String?
    private var email: String?
    private var phone: Int?
    private var fName: String?
    private var lName: String?
    private var displayImage: PFFileObject?
    
    init(userID currUser: PFObject){
        self.objectId = currUser.objectId
        self.email = currUser.value(forKey: "email") as? String
        self.phone = currUser.value(forKey: "phone") as? Int
        self.fName = currUser.value(forKey: "fName") as? String
        self.lName = currUser.value(forKey: "lName") as? String
        self.displayImage = currUser.value(forKey: "displayImage") as? PFFileObject
    }
    
    func getObjectId() -> String {
       return self.objectId!
    }
    
    func getFname() -> String {
        return self.fName!
    }
    
    func getLname() -> String {
        return self.lName!
    }
    
    func getName() -> String {
        return getFname() + " " + getLname()
    }
    
    func getPhone() -> Int {
        return self.phone!
    }
    
    func getPhoneAsString() -> String {
        return String(getPhone())
    }
    
    func getEmail() -> String {
        return self.email!
    }
    
    func getImage()-> PFFileObject {
        return self.displayImage!
    }
        
}
