//
//  ManageShopViewController.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse

class MyInventoryViewController: UIViewController {

    @IBOutlet weak var updateProducts: UIButton!
    @IBOutlet weak var finances: UIButton!
    @IBOutlet weak var requests: UIButton!
    
    var shopManager = ShopManager()
    var myRequests : [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButtons(buttons: [updateProducts, finances, requests])
        shopManager.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "goToUpdateProduct" {
            let destination = segue.destination as! UpdateProductCollectionViewController
            destination.setProducts(products: shopManager.getCurrProducts())
        }
        
        if segue.identifier! == "goToRequests" {
            let destination = segue.destination as! RequestsViewController
            print(self.myRequests.count)
            destination.setRequests(requests: self.myRequests)
        }
    }
    
    @IBAction func updateClicked(_ sender: Any) {
        self.shopManager.checkShop(identifier: "goToUpdateProduct")
    }
    
    @IBAction func financesClicked(_ sender: Any) {
    }
    
    @IBAction func requestsClicked(_ sender: Any) {
        myRequests.removeAll()
        let query = PFQuery(className: "Shop")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                let currShop = Shop(shop: object)
                let query = PFQuery(className: "Request")
                query.whereKey("shopId", contains: currShop.getShopId())
                query.whereKey("fulfilled", equalTo: false)
                query.findObjectsInBackground{(requests: [PFObject]? , error: Error?) in
                    if let requests = requests {
                        for request in requests {
                            let newRequest = Request(request: request)
                            self.myRequests.append(newRequest)
                        }
                        self.performSegue(withIdentifier: "goToRequests", sender: self)
                    }
                    else {
                        print("No Requests found")
                    }
                }
            }
        }
    }

}

extension MyInventoryViewController: shopManagerDelegate {
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}
