//
//  ManageShopViewController.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse

/**/
/*
class MyInventoryViewController

DESCRIPTION
        This class is a UIViewController that controls ManageShop.storyboard's MyInvetory view.
AUTHOR
        Rahul Guni
DATE
        07/24/2021
*/
/**/

class MyInventoryViewController: UIViewController {

    //IBOutlet elements
    @IBOutlet weak var updateProducts: UIButton!
    @IBOutlet weak var finances: UIButton!
    @IBOutlet weak var requests: UIButton!
    
    var shopManager = ShopManager()     //ShopManager Delegate to perform segues to specified destinations.
    var myRequests : [Request] = []     //All requests for current Shop
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButtons(buttons: [updateProducts, finances, requests])
        shopManager.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "goToUpdateProduct" {
            let destination = segue.destination as! UpdateProductCollectionViewController
            destination.setShop(shop: shopManager.getCurrShop())
            destination.setProducts(products: shopManager.getCurrProducts())
        }
        if(segue.identifier! == "goToRequests") {
            let destination = segue.destination as! RequestsViewController
            destination.setRequests(requests: myRequests)
            destination.setShop(shop: shopManager.getCurrShop())
        }
    }
}

//MARK:- ShopManagerDelegate
extension MyInventoryViewController: shopManagerDelegate {
    
    //Function to perform segue
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}

//MARK:- IBOutlet Functions
extension MyInventoryViewController {
    
    //Perform segue to UpdateProductCollectionViewContoller when Update Products button is clicked
    @IBAction func updateClicked(_ sender: Any) {
        self.shopManager.checkShop(identifier: "goToUpdateProduct")
    }
    
    @IBAction func financesClicked(_ sender: Any) {
    }
    
    /**/
    /*
    @IBAction func requestsClicked(_ sender: Any)

    NAME

           requestsClicked - Action for Requests Button Click.

    DESCRIPTION

            This function fetches the Request Table from current shop's objectId and records it in myRequests array before performing segue to RequestViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    @IBAction func requestsClicked(_ sender: Any) {
        myRequests.removeAll()
        //Query Shop First
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().userId, equalTo: currentUser!.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                let currShop = Shop(shop: object)
                self.shopManager.setShop(shop: currShop)
                //Query Shop Requests
                let query = PFQuery(className: ShopIO.Request().tableName)
                query.whereKey(ShopIO.Request().shopId, equalTo: currShop.getShopId())
                query.whereKey(ShopIO.Request().fulfilled, equalTo: false)
                query.findObjectsInBackground{(requests: [PFObject]? , error: Error?) in
                    if let requests = requests {
                        for request in requests {
                            let newRequest = Request(request: request)
                            self.myRequests.append(newRequest)
                        }
                        self.performSegue(withIdentifier: "goToRequests", sender: self)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to connect", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
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
    /* @IBAction func requestsClicked(_ sender: Any) */
}

//MARK:- Display Functions
extension MyInventoryViewController {
    
}
