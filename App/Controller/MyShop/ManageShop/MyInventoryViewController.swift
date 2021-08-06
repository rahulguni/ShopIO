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
    }
    
    @IBAction func updateClicked(_ sender: Any) {
        self.shopManager.checkShop(identifier: "goToUpdateProduct")
    }
    
    @IBAction func financesClicked(_ sender: Any) {
    }
    
    @IBAction func requestsClicked(_ sender: Any) {
    }

}

extension MyInventoryViewController: shopManagerDelegate {
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}
