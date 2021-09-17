//
//  ShopManager.swift
//  App
//
//  Created by Rahul Guni on 7/30/21.
//

import Foundation
import Parse

protocol shopManagerDelegate {
    func goToViewController(identifier: String)
}

class ShopManager {
    private var currShop: Shop?
    private var currProducts: [Product] = []
    var delegate: shopManagerDelegate?
    
    func setShop(shop: Shop) {
        self.currShop = shop
    }
    
    func getCurrShop() -> Shop {
        return self.currShop!
    }
    
    func getCurrProducts() -> [Product] {
        return self.currProducts
    }
    
    func checkShop(identifier: String) {
        //see if user already has a shop, if not go to register shop option.
        let query = PFQuery(className: "Shop")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                self.currShop = Shop(shop: object)
                self.getProducts(identifier: identifier)
            }
            else {
                self.delegate?.goToViewController(identifier: "goToAddShopView")
            }
        }
    }
    
    func goToShop(shop: Shop, identifier: String) {
        //see if user already has a shop, if not go to register shop option.
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: shop.getShopId())
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if object != nil {
                self.currShop = Shop(shop: object)
                self.getProducts(identifier: identifier)
            }
        }
    }
    
    func getProducts(identifier: String) {
        //check if the user has products to load up in the next view
        self.currProducts.removeAll()
        let query = PFQuery(className: "Product")
        query.whereKey("shopId", equalTo: self.currShop!.getShopId())
        query.order(byAscending: "title")
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let products = products {
                for currProduct in products {
                    let tempProduct = Product(product: currProduct)
                    self.currProducts.append(tempProduct)
                }
                self.delegate?.goToViewController(identifier: identifier)
            }
        }
    }
    
}
