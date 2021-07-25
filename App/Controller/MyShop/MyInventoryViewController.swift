//
//  ManageShopViewController.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit

class MyInventoryViewController: UIViewController {
    @IBOutlet weak var updateProducts: UIButton!
    @IBOutlet weak var finances: UIButton!
    @IBOutlet weak var requests: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        modifyButtons(buttons: [updateProducts, finances, requests])
    }

}
