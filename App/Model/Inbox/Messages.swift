import Foundation
import Parse

/**/
/*
class Message

DESCRIPTION
        This class is a PFObject class that is used for LiveQuery when rendering the messages.
        link:- https://docs.parseplatform.org/parse-server/guide/#live-queries
 
AUTHOR
        Rahul Guni
 
DATE
        08/18/2021
 
*/
/**/

class Messages: PFObject, PFSubclassing {
    @NSManaged var senderId: String?        //objectId of sender (which is always the user and never the shop)
    @NSManaged var receiverId: String?      //objectId of receiver (which is always the shop and never the user)

    //Returns the Parse database table where messages are stored
    class func parseClassName() -> String {
        return ShopIO.Messages().tableName
    }
}
