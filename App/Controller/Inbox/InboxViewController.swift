import UIKit
import Parse

/**/
/*
class InboxViewController

DESCRIPTION
        This class is a UIViewController that controls Inbox.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        08/16/2021
 
*/
/**/

class InboxViewController: UIViewController {
    
    //IBOutlet elements
    @IBOutlet weak var myInboxButton: UIButton!
    @IBOutlet weak var shopInboxButton: UIButton!
    
    //Controller parameters
    private var myMessages: [MessageModel] = [] //an array of MessageModel objects to pass messages to the next controller
    private var forShop: Bool = false           //determines whether the next view controller is for shop inbox or user inbox
    private var currSender: Sender?             //an object of Sender Class to render messages appropriately
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButtons(buttons: [myInboxButton, shopInboxButton])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forInbox
        }
        
        if(segue.identifier! == "goToMessages") {
            let destination = segue.destination as! MyMessagesViewController
            destination.setMessages(messages: self.myMessages)
            destination.setForShop(bool: forShop)
            destination.setSender(currSender: self.currSender!)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToInboxWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
   
}

//MARK:- IBOutlet Functions
extension InboxViewController {
    
    /**/
    /*
    @IBAction func myInboxClicked(_ sender: Any)

    NAME

           myInboxClicked - Action for button myInboxButton click.

    DESCRIPTION

            This function first checks if the user is signed in. If true, it fetches all messages for the user and performs
            segue to MessagesViewController. If the user is not signed in, the sign in view appears.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/16/2021

    */
    /**/
    
    @IBAction func myInboxClicked(_ sender: Any) {
        self.myMessages.removeAll()
        self.forShop = false
        if(currentUser != nil) {
            getAllUserMessages(id: currentUser!.objectId!, forShop: self.forShop)
            self.currSender = Sender(senderId: currentUser!.objectId!, displayName: currentUser!.value(forKey: ShopIO.User().fName) as! String)
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    /*@IBAction func myInboxClicked(_ sender: Any)*/
    
    /**/
    /*
    @IBAction func shopInboxClicked(_ sender: Any)

    NAME

           shopInboxClicked - Action for button shopInboxButton click.

    DESCRIPTION

            This function first checks if the user has a shop registered in the Shop table. If true, it fetches all
            the messages for shop and segues to MessagesViewController. If false, AddShop View Controller is loaded.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/16/2021

    */
    /**/
    
    @IBAction func shopInboxClicked(_ sender: Any) {
        self.myMessages.removeAll()
        //get shop first
        self.forShop = true
        let query = PFQuery(className: ShopIO.Shop().tableName)
        if(currentUser != nil) {
            query.whereKey(ShopIO.Shop().userId, equalTo: currentUser!.objectId!)
            query.getFirstObjectInBackground{(object, error) in
                if(object != nil) {
                    self.getAllUserMessages(id: object!.objectId! as String, forShop: self.forShop)
                    self.currSender = Sender(senderId: object!.objectId!, displayName: object!.value(forKey: ShopIO.Shop().title) as! String)
                }
                else {
                    self.performSegue(withIdentifier: "goToAddShop", sender: self)
                }
            }
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    /*@IBAction func shopInboxClicked(_ sender: Any)*/
}

//MARK:- General functions
extension InboxViewController{
    
    /**/
    /*
    private func getAllUserMessages(id userId: String, forShop: Bool)

    NAME

            getAllUserMessages - Get all messages for the objectId passed in.
     
    SYNOPSIS
           
            getAllUserMessages(id userId: String, forShop: Bool)
                userId      --> objectId of user if messages fetched for user, objectId of shop if messages fetched for shop.
                forShop     --> Determines if messages to be fetched is for user or shop

    DESCRIPTION

            This function takes in the objectId for which messages is to be fetched. The forShop boolean variable determines
            this when passed on from the IBOutlet functions. After the search in Message Table in database is completed, the
            objects are appeneded to myMessages array and the controller is segued to MessagesViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/16/2021

    */
    /**/
    
    private func getAllUserMessages(id userId: String, forShop: Bool){
        let query = PFQuery(className: ShopIO.Messages().tableName)
        if(forShop) {
            query.whereKey(ShopIO.Messages().receiverId, equalTo: userId)
        }
        else {
            query.whereKey(ShopIO.Messages().senderId, equalTo: userId)
        }
        query.order(byDescending: ShopIO.Messages().updatedAt)
        query.findObjectsInBackground{(messages: [PFObject]? , error: Error?) in
            if let messages = messages {
                for message in messages {
                    let sender: String = message.value(forKey: ShopIO.Messages().senderId) as! String
                    let receiver: String = message.value(forKey: ShopIO.Messages().receiverId) as! String
                    let chatRoomId: String = message.objectId!
                    let newMessage = MessageModel(sender: sender, receiver: receiver, chatRoomId: chatRoomId)
                    self.myMessages.append(newMessage)
                }
                self.performSegue(withIdentifier: "goToMessages", sender: self)
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /*private func getAllUserMessages(id userId: String, forShop: Bool)*/
    
}

