//
//  EditShopViewController.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//

import UIKit

class EditShopViewController: UIViewController {
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var updateInventory: UIButton!
    @IBOutlet weak var orders: UIButton!
    
    private var currShop: Shop?
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToEditShopWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toAddProduct") {
            let destination = segue.destination as! AddProductViewController
            destination.setShop(shop: currShop)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentButtons: [UIButton] = [addProduct, updateInventory, orders]
        modifyButtons(buttons: currentButtons)
    }
    
    func setShop(shop: Shop?) {
        self.currShop = shop
    }

}
