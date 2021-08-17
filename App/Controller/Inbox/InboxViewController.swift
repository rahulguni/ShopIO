//
//  InboxViewController.swift
//  App
//
//  Created by Rahul Guni on 8/16/21.
//

import UIKit
import Parse
import ParseLiveQuery

class InboxViewController: UIViewController {
    
    @IBOutlet weak var myInboxButton: UIButton!
    @IBOutlet weak var shopInboxButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButtons(buttons: [myInboxButton, shopInboxButton])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forInbox
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
        if(currentUser != nil) {
            
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    @IBAction func shopInboxClicked(_ sender: Any) {
    }
    
}

//MARK:- Diaplay functions
extension InboxViewController{
    
    func test() {
        let query = PFQuery(className: "Messages")
        query.whereKey("receiverId", equalTo: currentUser!.objectId!)
        query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) in
            if(error != nil) {
                
            }
        }
    }
}

