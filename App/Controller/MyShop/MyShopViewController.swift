//
//  MyShop.swift
//  App
//
//  Created by Rahul Guni on 4/30/21.
//

import UIKit
import Parse

class MyShopViewController: UIViewController{
    
    @IBOutlet weak var myShopButton: UIButton!
    @IBOutlet weak var editMyShopButton: UIButton!
    @IBOutlet weak var AddNewShop: UIButton!
    
    private var currShop: Shop?
    private var currProducts: [Product] = []
    
    override func viewDidLoad() {
        let currentButtons: [UIButton] = [myShopButton, editMyShopButton, AddNewShop]
        modifyButtons(buttons: currentButtons)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Make sure to render the right buttons for managing shop
        if currentUser == nil {
            alterButtons(loggedIn: false)
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
        else{
            alterButtons(loggedIn: true)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyShopWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //function to dismiss the signIn view after login when called from myshop view.
        if(segue.identifier! == "toSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = true
        }
        
        if(segue.identifier! == "goTomyShopView") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: currShop)
            destination.fillMyProducts(productsList: currProducts)
            destination.setOwner(true)
        }
        
        if(segue.identifier! == "goToManageShop") {
            let destination = segue.destination as! ManageShopViewController
            destination.setShop(shop: currShop)
        }
        
    }
    
    @IBAction func manageShopButton(_ sender: UIButton) {
        if currentUser != nil{
            checkShop(identifier: "goToManageShop")
        }
        else{
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    @IBAction func myShopButton(_ sender: UIButton) {
        if currentUser != nil {
            currProducts = []
            checkShop(identifier: "goTomyShopView")
        }
        else {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    
    @IBAction func AddNewShop(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    
    private func alterButtons(loggedIn bool: Bool) {
        AddNewShop.isHidden = bool;
        myShopButton.isHidden = !bool;
        editMyShopButton.isHidden = !bool;
    }
    
    private func checkShop(identifier: String) {
        //see if user already has a shop, if not go to register shop option.
        let query = PFQuery(className: "Shop")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                self.currShop = Shop(shop: object)
                self.getProducts(identifier: identifier)
            }
            else {
                self.performSegue(withIdentifier: "goToAddShopView", sender: self)
            }
        }
    }
    
    private func getProducts(identifier: String) {
        //check if the user has products to load up in the next view
        let query = PFQuery(className: "Product")
        query.whereKey("shopId", equalTo: self.currShop!.getShopId())
        query.order(byAscending: "title")
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let error = error {
                //Request failed
                print(error.localizedDescription)
            }
            else if let products = products {
                for currProduct in products {
                    let tempProduct = Product(product: currProduct)
                    self.currProducts.append(tempProduct)
                }
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }
    
    func setShop(shop: Shop?) {
        self.currShop = shop
    }
    
}
