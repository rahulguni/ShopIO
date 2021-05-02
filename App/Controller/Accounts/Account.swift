//
//  ViewController.swift
//  App
//
//  Created by Rahul Guni on 4/25/21.
//

import UIKit
import Parse

class Account: UIViewController {

    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var accountTitle: UITextField!
    
    let headers = AccountTableOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountTable.delegate = self
        accountTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadViewData()
    }
    
    //Function to unwind the segue and reload table cells
    @IBAction func unwindToAccountsWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.reloadViewData()
            }
        }
    }
    
    //function to reload the view according to if a user is signed in
    func reloadViewData(){
        if let user = currentUser {
            if let name = user.value(forKey: "fName"){
                accountTitle.text = "Welcome, \(name)"
            }
        }
        else{
            accountTitle.text = "Welcome"
        }
        accountTable.reloadData()
        //If table reloaded after sign out button clicked, scroll to the top of the table
        if currentUser == nil {
            let indexPath = IndexPath(row: 0, section: 0)
            accountTable.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

}

extension Account: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Perform Segue to Sign In Page if Sign In is clicked.
        if(indexPath == [0,0]){
            performSegue(withIdentifier: "goToSignIn", sender: self)
        }
        
        //Sign out the user if Sign Out is selected
        if(indexPath == [4,0]) {
            let alert = UIAlertController(title: "Are you sure you want to sign off?", message: "Please select below", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sign Out", comment: "Sign Out Button"), style: .default, handler: { _ in
                PFUser.logOut()
                currentUser = PFUser.current()
                DispatchQueue.main.async{
                    self.reloadViewData()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

extension Account: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(currentUser != nil && section == 0) {
            return 0.0
        }
        if(currentUser == nil && section == 4) {
            return 0.0
        }
        return 40.0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.cells.count
    }
    
    //Render sign in and sign out options from table sections according to current user
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentUser != nil && section == 0) {
            return 0
        }
        if (currentUser == nil && section == 4) {
            return 0
        }
        return headers.cells[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
        cell.textLabel?.text = headers.cells[indexPath.section][indexPath.row]
        return cell
    }
    
    
}