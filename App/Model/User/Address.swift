import Foundation
import Parse

/**/
/*
class Address

DESCRIPTION
        This class is the model to render data from Address database. This class also has all the setter and getter properies for the parameters.
 
AUTHOR
        Rahul Guni
 
DATE
        07/15/2021
 
*/
/**/

struct Address {
    private var objectId: String?   //objectId of the address
    private var userId: String?     //userId of the address, foreign key to user table
    private var line_1: String?
    private var line_2: String?
    private var city: String?
    private var state: String?
    private var country: String?
    private var zip: String?
    private var phone: Int?
    private var geoLocation: PFGeoPoint? //geoLocation of the address
    
    //constructor
    init(address addressObject: PFObject?){
        self.objectId = addressObject!.objectId
        self.userId = addressObject![ShopIO.Address().objectId] as? String
        self.line_1 = addressObject![ShopIO.Address().line1] as? String
        self.line_2 = addressObject![ShopIO.Address().line2] as? String
        self.city = addressObject![ShopIO.Address().city] as? String
        self.state = addressObject![ShopIO.Address().state] as? String
        self.zip = addressObject![ShopIO.Address().zip] as? String
        self.phone = addressObject![ShopIO.Address().phone] as? Int
        self.country = addressObject![ShopIO.Address().country] as? String
        self.geoLocation = addressObject![ShopIO.Address().geoPoints] as? PFGeoPoint
    }
    
    func getObjectId() -> String {
        return self.objectId!
    }
    
    func getLine1() -> String? {
        return self.line_1!
    }
    
    func getLine2() -> String? {
        return self.line_2!
    }
    
    func getCity() -> String? {
        return self.city
    }
    
    func getState() -> String? {
        return self.state
    }
    
    func getCountry() -> String? {
        return self.country
    }
    
    func getZip() -> String? {
        return self.zip
    }
    
    func getPhone() -> Int? {
        return self.phone
    }
    
    func getAddressForCheckOut() -> String {
        return self.line_1! + ", " + self.city!
    }
    
    func getFullAddress() -> String {
        return self.line_1! + ", " + self.city! + ", " + self.state! + ", " + self.zip! + ", " + self.country!
    }
    
    //Function to print address for Order
    func getAddressForOrder() -> String {
        let address = "Ship To: " + "\n" + self.line_1! + ", " + self.line_2! + "\n" + self.city! + ", " + self.state! + "\n" + self.zip!
        return address
    }
    
    func getGeoPoints() -> PFGeoPoint {
        return self.geoLocation!
    }
    
}
