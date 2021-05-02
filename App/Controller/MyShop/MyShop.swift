//
//  MyShop.swift
//  App
//
//  Created by Rahul Guni on 4/30/21.
//

import UIKit
import Parse

class MyShop: UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser == nil {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
}
