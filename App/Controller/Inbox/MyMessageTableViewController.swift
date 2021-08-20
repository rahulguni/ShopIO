//
//  MyMessageTableViewController.swift
//  App
//
//  Created by Rahul Guni on 8/20/21.
//

import UIKit

class MyMessageTableViewController: UITableViewController {
    
    private var myMessages: [ChatRoom] = []
    private var senderImage: UIImage?
    private var currSender: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.myMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableMyMessageCell", for: indexPath) as! MyMessageTableViewCell
        cell.setParameters(displayImage: senderImage! , message: myMessages[indexPath.row].getMessage())
        if(myMessages[indexPath.row].getSenderId() == self.currSender) {
            cell.setCellForSender()
        }
        return cell
    }

    func setImage(sender: UIImage) {
        self.senderImage = sender
    }
    
    func setMessages(messages: [ChatRoom]) {
        self.myMessages = messages
    }
    
    func setCurrSender(currSender: String) {
        self.currSender = currSender
    }

}
