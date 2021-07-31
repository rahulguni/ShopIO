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
    
    var shopManager = ShopManager()
    
    override func viewDidLoad() {
        let currentButtons: [UIButton] = [myShopButton, editMyShopButton, AddNewShop]
        modifyButtons(buttons: currentButtons)
        shopManager.delegate = self
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
            destination.dismiss = forSignIn.forMyShop
        }
        
        if(segue.identifier! == "goTomyShopView") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: shopManager.getCurrShop())
            destination.fillMyProducts(productsList: shopManager.getCurrProducts())
            destination.setForShop(forProducts.forMyShop)
        }
        
        if(segue.identifier! == "goToManageShop") {
            let destination = segue.destination as! ManageShopViewController
            destination.setShop(shop: shopManager.getCurrShop())
        }
        
    }
    
    @IBAction func manageShopButton(_ sender: UIButton) {
        if currentUser != nil{
            self.shopManager.checkShop(identifier: "goToManageShop")
        }
        else{
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    @IBAction func myShopButton(_ sender: UIButton) {
        if currentUser != nil {
            self.shopManager.checkShop(identifier: "goTomyShopView")
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
    
}

extension MyShopViewController: shopManagerDelegate {
    
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
        
}
