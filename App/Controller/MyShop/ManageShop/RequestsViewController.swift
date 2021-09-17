//
//  RequestsViewController.swift
//  App
//
//  Created by Rahul Guni on 8/7/21.
//

import UIKit
import Parse

class RequestsViewController: UIViewController {

    @IBOutlet weak var requestsTable: UITableView!
    
    private var requests : [Request] = []
    private var currShop: Shop?
    private var currProduct: Product?
    private var currProductImage: [ProductImage] = []
    private var requestIndex: Int?
        
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
    
    func setRequests(requests currRequests: [Request]) {
        self.requests = currRequests
    }
    
    func setShop(shop currShop: Shop) {
        self.currShop = currShop
    }
    
    func getProduct(currRequest: Request){
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: currRequest.getProductId())
        query.getFirstObjectInBackground{(product, error) in
            if let product = product {
                self.currProduct = Product(product: product)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: "Product_Images")
                query.whereKey("productId", equalTo: self.currProduct!.getObjectId())
                query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
                    if let objects = objects {
                        for object in objects {
                            let productImage = ProductImage(image: object)
                            self.currProductImage.append(productImage)
                        }
                    }
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
    
    func fulfillRequest(currRequest: Request, currProduct: Product) {
        //changed fulfilled to true
        let query = PFQuery(className: "Request")
        query.whereKey("objectId", equalTo: currRequest.getObjectId())
        query.getFirstObjectInBackground{(request, error) in
            if let request = request {
                request["fulfilled"] = true
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
    
    func deleteRequest(currRequest: Request, currProduct: Product) {
        let query = PFQuery(className: "Request")
        query.whereKey("objectId", equalTo: currRequest.getObjectId())
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
    
    func sendMessage(currRequest: Request, currProduct: Product) {
        //search if chatroom already exists
        let query = PFQuery(className: "Messages")
        query.whereKey("receiverId", equalTo: currShop!.getShopId())
        query.whereKey("senderId", equalTo: currRequest.getUserId())
        query.getFirstObjectInBackground{(message, error) in
            if let message = message {
                //chatRoom already exists, add to chat.
                self.saveChat(message: message, currProduct: currProduct)
                message["updatedAt"] = Date()
                message.saveInBackground()
            }
            //if not exists, create one and send message.
            else {
                let message = PFObject(className: "Messages")
                message["senderId"] = currRequest.getUserId()
                message["receiverId"] = self.currShop!.getShopId()
                
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
    
    func saveChat(message: PFObject, currProduct: Product) {
        let chatRoom = PFObject(className: "ChatRoom")
        chatRoom["chatRoomId"] = message.objectId!
        chatRoom["senderId"] = self.currShop!.getShopId()
        chatRoom["message"] = "Your request for \(currProduct.getTitle()) has been accepted. Please head over to our shop and add to your cart to check out. Thank you for your patience."
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
}

//MARK:- UITableViewDelegate
extension RequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.requestIndex = indexPath.row
        let currRequest = requests[requestIndex!]
        self.getProduct(currRequest: currRequest)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension RequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableRequestsCell") as! RequestsTableViewCell
        cell.setParameters(request: requests[indexPath.row])
        return cell
    }
}
