import Foundation
import Parse

/**/
/*
class Message

DESCRIPTION
        This class is a PFObject class that is used for LiveQuery when rendering the chatRoom. link:- https://docs.parseplatform.org/parse-server/guide/#live-queries
AUTHOR
        Rahul Guni
DATE
        08/20/2021
*/
/**/

class MyChatRoom: PFObject, PFSubclassing {
    @NSManaged var senderId: String?
    @NSManaged var content: String?
    @NSManaged var chatRoomId: String?

    //Returns the Parse database table where messages are stored
    class func parseClassName() -> String {
        return "ChatRoom"
    }
}
