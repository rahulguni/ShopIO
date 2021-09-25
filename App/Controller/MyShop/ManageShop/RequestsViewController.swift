import UIKit
import Parse

/**/
/*
class RequestsViewController

DESCRIPTION
        This class is a UIViewController that controls Requests.storyboard View.
AUTHOR
        Rahul Guni
DATE
        08/07/2021
*/
/**/

class RequestsViewController: UIViewController {

    //IBOutlet Elements
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //Controller parameters
    private var requests : [Request] = []               //all requests, passed on from MyInventoryViewController
    private var currShop: Shop?                         //current shop
    private var currProduct: Product?                   //selected product
    private var currProductImage: [ProductImage] = []   //selected product's images
    private var requestIndex: Int?                      //for current product's array index
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestsTable.delegate = self
        requestsTable.dataSource = self

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: currProduct!)
            destination.setImages(myImages: self.currProductImage)
            destination.productMode = ProductMode.forRequest
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyRequestsWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.requestsTable.reloadData()
            }
        }
    }
}

//MARK:- Display Functions
extension RequestsViewController {
    
    //Setter function to set up current Requests, passed on from previous view controller (MyInventoryViewController)
    func setRequests(requests currRequests: [Request]) {
        self.requests = currRequests
    }
    
    //Setter function to set up current Shop, passed on from previous view controller (InboxViewController)
    func setShop(shop currShop: Shop) {
        self.currShop = currShop
    }
    
    /**/
    /*
    private func getProduct(currRequest: Request)

    NAME

            getProduct - Current Product for request
     
    SYNOPSIS
           
            getProduct(currRequest: Request)
                currRequest      --> Request object to find product

    DESCRIPTION

            This function takes in the Request object and queries the Products table through the Request object's productId. Then it presents a .form alert for different choices for the request:- View Product, fulfill request or delete request.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    private func getProduct(currRequest: Request){
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().objectId, equalTo: currRequest.getProductId())
        query.getFirstObjectInBackground{(product, error) in
            if let product = product {
                self.currProduct = Product(product: product)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: ShopIO.Product_Images().tableName)
                query.whereKey(ShopIO.Product_Images().productId, equalTo: self.currProduct!.getObjectId())
                query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
                    if let objects = objects {
                        for object in objects {
                            let productImage = ProductImage(image: object)
                            self.currProductImage.append(productImage)
                        }
                    }
                    
                    //present alert after query
                    let alert = UIAlertController(title: "Request", message: "Choose what you want to do with this request.", preferredStyle: .alert)
                    
                    //view Product Option
                    alert.addAction(UIAlertAction(title: "View Product", style: .default, handler: {action in
                        self.performSegue(withIdentifier: "goToMyProduct", sender: self)
                    }))
                    
                    //Fulfill Request Option
                    alert.addAction(UIAlertAction(title: "Fulfill Request", style: .default, handler: {action in
                        self.fulfillRequest(currRequest: currRequest, currProduct: self.currProduct!)
                    }))
                    
                    //Delete Reauest Option
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                        self.deleteRequest(currRequest: currRequest, currProduct: self.currProduct!)
                    }))

                    self.present(alert, animated: true)
                }
            }
            else{
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getProduct(currRequest: Request) */
    
    /**/
    /*
    private func fulfillRequest(currRequest: Request, currProduct: Product)

    NAME

            fulfillRequest - Fulfills current request
     
    SYNOPSIS
           
            fulfillRequest(currRequest: Request, currProduct: Product)
                currRequest      --> Request object
                currProduct      --> Product for request

    DESCRIPTION

            This function queries the request table and marks the request as fulfilled. currProduct is used to send current Product and request details to customer as a message.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    private func fulfillRequest(currRequest: Request, currProduct: Product) {
        //changed fulfilled to true
        let query = PFQuery(className: ShopIO.Request().tableName)
        query.whereKey(ShopIO.Request().objectId, equalTo: currRequest.getObjectId())
        query.getFirstObjectInBackground{(request, error) in
            if let request = request {
                request[ShopIO.Request().fulfilled] = true
                request.saveInBackground{(success, error) in
                    if(success) {
                        self.sendMessage(currRequest: currRequest, currProduct: currProduct)
                    }
                    else{
                        let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to fulfill request.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func fulfillRequest(currRequest: Request, currProduct: Product) */
    
    /**/
    /*
    private func deleteRequest(currRequest: Request, currProduct: Product)

    NAME

            deleteRequest - Deletes current request
     
    SYNOPSIS
           
            fulfillRequest(currRequest: Request, currProduct: Product)
                currRequest      --> Request object
                currProduct      --> Product for request

    DESCRIPTION

            This function queries the request table and deletes the request. currProduct is used to send current Product and request details to customer as a message.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    
    private func deleteRequest(currRequest: Request, currProduct: Product) {
        let query = PFQuery(className: ShopIO.Request().tableName)
        query.whereKey(ShopIO.Request().objectId, equalTo: currRequest.getObjectId())
        query.getFirstObjectInBackground{(request, error) in
            if let request = request {
                request.deleteInBackground{(success, error) in
                    if(success) {
                        self.requests.remove(at: self.requestIndex!)
                        self.requestsTable.reloadData()
                        let alert = customNetworkAlert(title: "Successfully deleted request.", errorString: "This request has been deleted.")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to delete request.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func deleteRequest(currRequest: Request, currProduct: Product)*/
    
    /**/
    /*
    private func sendMessage(currRequest: Request, currProduct: Product)

    NAME

            sendMessage - Uploads/Updates Message to create a chatRoom.
     
    SYNOPSIS
           
            sendMessage(currRequest: Request, currProduct: Product)
                currRequest      --> Request object
                currProduct      --> Product for request

    DESCRIPTION

            This function first checks if a chatRoom already exists for the two parties to exchange messages. If not, it creates a new Message Model and open a chatRoom.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    private func sendMessage(currRequest: Request, currProduct: Product) {
        //search if chatroom already exists
        let query = PFQuery(className: ShopIO.Messages().tableName)
        query.whereKey(ShopIO.Messages().receiverId, equalTo: currShop!.getShopId())
        query.whereKey(ShopIO.Messages().senderId, equalTo: currRequest.getUserId())
        query.getFirstObjectInBackground{(message, error) in
            if let message = message {
                //chatRoom already exists, add to chat.
                self.saveChat(message: message, currProduct: currProduct)
                message[ShopIO.Messages().updatedAt] = Date()
                message.saveInBackground()
            }
            //if not exists, create one and send message.
            else {
                let message = PFObject(className: ShopIO.Messages().tableName)
                message[ShopIO.Messages().senderId] = currRequest.getUserId()
                message[ShopIO.Messages().receiverId] = self.currShop!.getShopId()
                
                message.saveInBackground{(success, error) in
                    if(success) {
                        self.saveChat(message: message, currProduct: currProduct)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Error", errorString: "Could not message at this time.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    /* private func sendMessage(currRequest: Request, currProduct: Product)*/
    
    /**/
    /*
    private func saveChat(message: PFObject, currProduct: Product)

    NAME

            saveChat - Uploads message in a chatRoom.
     
    SYNOPSIS
           
            saveChat(message: PFObject, currProduct: Product)
                message      --> Message PFObject passed on from sendMessage()
                currProduct      --> Product for request

    DESCRIPTION

            This function takes in a PFObject for the objectId of the chatRoom and uploads a message including the currProduct's details and request details to the user in chatRoom table.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/07/2021

    */
    /**/
    
    private func saveChat(message: PFObject, currProduct: Product) {
        let chatRoom = PFObject(className: ShopIO.ChatRoom().tableName)
        chatRoom[ShopIO.ChatRoom().chatRoomId] = message.objectId!
        chatRoom[ShopIO.ChatRoom().senderId] = self.currShop!.getShopId()
        chatRoom[ShopIO.ChatRoom().message] = "Your request for \(currProduct.getTitle()) has been accepted. Please head over to our shop and add to your cart to check out. Thank you for your patience."
        chatRoom.saveEventually {(success, error) in
            if(success) {
                let alert = UIAlertController(title: "Your request has been marked fulfilled.", message: "Please update your product quantity from your inventory.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                    self.requests.remove(at: self.requestIndex!)
                    self.performSegue(withIdentifier: "goToMyProduct", sender: self)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = customNetworkAlert(title: "Your request has been marked fulfilled.", errorString: "Hoewever, There was an error connecting to the chat server. Please check your internet connection and notify your customer..")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /*  private func saveChat(message: PFObject, currProduct: Product) */
}

//MARK:- UITableViewDelegate
extension RequestsViewController: UITableViewDelegate {
    
    //get Product and present alert on cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.requestIndex = indexPath.row
        let currRequest = requests[requestIndex!]
        self.getProduct(currRequest: currRequest)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension RequestsViewController: UITableViewDataSource {
    
    //function to display number of cells in TableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    //function to populate the tableView cells, from RequestsTableViewCell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableRequestsCell") as! RequestsTableViewCell
        cell.setParameters(request: requests[indexPath.row])
        return cell
    }
}
