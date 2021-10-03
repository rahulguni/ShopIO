import UIKit
import Parse

/**/
/*
class AccountViewController

DESCRIPTION
        This class is a UIViewController that controls Account.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        04/25/2021
 
*/
/**/

// MARK: - UIView
class AccountViewController: UIViewController {
    
    //IBOutlet elements
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var accountTitle: UITextField!
    
    private let headers = AccountTableOptions()             //To load account options in tableviewcell.
    private var orders: [Order] = []                        //To pass orders to next view
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forAccount
        }
        
        if(segue.identifier! == "goToMyOrders") {
            let destination = segue.destination as! OrdersViewController
            destination.setOrders(orders: self.orders)
            destination.setMyOrders(bool: true)
        }
    }
    
}

//MARK:- Regular Functions
extension AccountViewController {

    /**/
    /*
    private func reloadViewData()

    NAME

           reloadViewData - Reloads current view with appropriate labels.

    DESCRIPTION

            This function reloads current View's title label if a user is signed in.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            04/25/2021

    */
    /**/
    
    private func reloadViewData(){
        if let user = currentUser {
            if let name = user.value(forKey: ShopIO.User().fName){
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
    /* private func reloadViewData() */
    
    /**/
    /*
    private func searchOrder()

    NAME

           searchOrder - Search for current user's orders

    DESCRIPTION

            This function queries the Orders table using current user's objectId and appends the order objects to orders array.
            Then. it performs segue to OrderViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            04/25/2021

    */
    /**/
    
    private func searchOrder() {
        self.orders.removeAll()
        let query = PFQuery(className: ShopIO.Order().tableName)
        query.whereKey(ShopIO.Order().userId, equalTo: currentUser!.objectId!)
        query.order(byDescending: ShopIO.Order().createdAt)
        query.findObjectsInBackground{(orders, error) in
            if let orders = orders {
                for order in orders {
                    self.orders.append(Order(order: order))
                }
                self.performSegue(withIdentifier: "goToMyOrders", sender: self)
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func searchOrder() */
    
    /**/
    /*
    private func signOut()

    NAME

           signOut - Sign Off the user

    DESCRIPTION

            This function signs the user off by deleting current user's sessionId in session table, and reloading the tableview.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            04/25/2021

    */
    /**/
    
    private func signOut() {
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
    /* private func signOut() */
}

//MARK: - UITableDelegate
extension AccountViewController: UITableViewDelegate{
    
    //Action for tableview cell click.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        
            //Perform Segue to Sign In Page if Sign In is clicked.
            case [0,0]:
                performSegue(withIdentifier: "goToSignIn", sender: self);
                
            //Perform Segue to Address if My Addresses is clicked.
            case[1,0]:
                if(currentUser != nil) {
                    performSegue(withIdentifier: "goToMyAddresses", sender: self)
                }
                else {
                    performSegue(withIdentifier: "goToSignIn", sender: self)
                }
                
            //Perform segue to Orders if Order History is clicked.
            case[1,2]:
                if(currentUser != nil) {
                    self.searchOrder()
                }
                else{
                    performSegue(withIdentifier: "goToSignIn", sender: self)
                }
            
            //Perform segue to Edit Profile if Edit Profile is clicked.
            case[2,2]:
                if(currentUser != nil) {
                    performSegue(withIdentifier: "goToEditProfile", sender: self)
                }
                else {
                    performSegue(withIdentifier: "goToSignIn", sender: self)
                }
            
                
            //Sign out the user if Sign Out is selected
            case [4,0]:
                self.signOut()
                
            default:
                return;
        }
    }
}

//MARK: - UITableDataSource
extension AccountViewController: UITableViewDataSource{
    
    //function to set header heights for cells
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return CGFloat.leastNormalMagnitude
        }
        return 20.0;
    }
    
    //function to set number of headers
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.cells.count
    }
    
    //function to render number of cells under each header.
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        return headers.headers[section]
    }
    
    //function to populate table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
        cell.textLabel?.text = headers.cells[indexPath.section][indexPath.row]
        return cell
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
    
}
