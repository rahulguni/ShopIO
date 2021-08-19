//
//  MessagesViewController.swift
//  App
//
//  Created by Rahul Guni on 8/19/21.
//

import UIKit
import Parse

class MessagesViewController: UIViewController{
    
    @IBOutlet weak var messagesTable: UITableView!
    
    private var myMessages: [MessageModel] = []
    private var forShop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //messagesTable.isHidden = true
        messagesTable.delegate = self
        messagesTable.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
}

//MARK:- Display Functions
extension MessagesViewController {
    
    func setForShop(bool: Bool) {
        self.forShop = bool
    }
    
    func setMessages(messages: [MessageModel]) {
        self.myMessages = messages
    }
}

//MARK:- UITableViewDelegate
extension MessagesViewController: UITableViewDelegate {
    
}

//MARK:- UITableViewDataSource
extension MessagesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMessageCell", for: indexPath) as! MessageTableViewCell
        cell.setParameters(forShop: forShop, message: myMessages[indexPath.row])
        return cell
    }
}






