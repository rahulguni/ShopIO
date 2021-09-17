//
//  InboxViewController.swift
//  App
//
//  Created by Rahul Guni on 8/16/21.
//

import UIKit
import Parse

class InboxViewController: UIViewController {
    
    @IBOutlet weak var myInboxButton: UIButton!
    @IBOutlet weak var shopInboxButton: UIButton!
    
    private var myMessages: [MessageModel] = []
    private var forShop: Bool = false
    private var currSender: Sender?
    
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
    
    @IBAction func myInboxClicked(_ sender: Any) {
        self.myMessages.removeAll()
        self.forShop = false
        if(currentUser != nil) {
            getAllUserMessages(id: currentUser!.objectId!, forShop: self.forShop)
            self.currSender = Sender(senderId: currentUser!.objectId!, displayName: currentUser!.value(forKey: "fName") as! String)
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    @IBAction func shopInboxClicked(_ sender: Any) {
        self.myMessages.removeAll()
        //get shop first
        self.forShop = true
        let query = PFQuery(className: "Shop")
        if(currentUser != nil) {
            query.whereKey("userId", equalTo: currentUser!.objectId!)
            query.getFirstObjectInBackground{(object, error) in
                if(object != nil) {
                    self.getAllUserMessages(id: object!.objectId! as String, forShop: self.forShop)
                    self.currSender = Sender(senderId: object!.objectId!, displayName: object!.value(forKey: "title") as! String)
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
    
}

//MARK:- Diaplay functions
extension InboxViewController{
    
    func getAllUserMessages(id userId: String, forShop: Bool){
        let query = PFQuery(className: "Messages")
        if(forShop) {
            query.whereKey("receiverId", equalTo: userId)
        }
        else {
            query.whereKey("senderId", equalTo: userId)
        }
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground{(messages: [PFObject]? , error: Error?) in
            if let messages = messages {
                for message in messages {
                    let sender: String = message.value(forKey: "senderId") as! String
                    let receiver: String = message.value(forKey: "receiverId") as! String
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
    
    
}

