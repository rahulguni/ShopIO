import Foundation
import MessageKit

/**/
/*
struct Sender

DESCRIPTION
        This struct is for MessageKit that helps render correct sender and receiever in the MessageTableView. Link:- https://github.com/MessageKit/MessageKit
 
AUTHOR
        Rahul Guni
 
DATE
        08/20/2021
 
*/
/**/

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

/**/
/*
struct MyMessage

DESCRIPTION
        This struct is for MessageKit that helps render correct sender and receiever in the MessageTableView. Link:- https://github.com/MessageKit/MessageKit
 
AUTHOR
        Rahul Guni
 
DATE
        08/20/2021
 
*/
/**/

struct MyMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
