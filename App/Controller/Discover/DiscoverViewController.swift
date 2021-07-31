//
//  DiscoverViewController.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse

class DiscoverViewController: UIViewController {

    @IBOutlet weak var shopCollection: UICollectionView!
    
    //a list to store all shops
    private var shops: [Shop] = []
    //to record selected shop
    private var currShop: Shop?
    //to transfer product list to shop view
    private var currProducts: [Product] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToShop") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: currShop)
            destination.fillMyProducts(productsList: currProducts)
            destination.setForShop(forProducts.forPublic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        shopCollection.delegate = self
        shopCollection.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Render all shops
        self.shops = []
        let shopQuery = PFQuery(className: "Shop")
        shopQuery.whereKey("userId", notEqualTo: currentUser?.objectId ?? "")
        shopQuery.order(byAscending: "title")
        shopQuery.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            if let objects = objects {
                for object in objects {
                    let newShop = Shop(shop: object)
                    let productQuery = PFQuery(className: "Product")
                    productQuery.whereKey("shopId", equalTo: newShop.getShopId())
                    productQuery.getFirstObjectInBackground{(object: PFObject?, error: Error?) in
                        if(object != nil) {
                            self.shops.append(newShop)
                        }
                        self.shopCollection.reloadData()
                    }
                }
            }
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currShop = shops[indexPath.row]
        currProducts = []
        let query = PFQuery(className: "Product")
        query.whereKey("shopId", equalTo: currShop!.getShopId())
        query.order(byAscending: "title")
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let products = products {
                for currProduct in products {
                    let tempProduct = Product(product: currProduct)
                    self.currProducts.append(tempProduct)
                }
                self.performSegue(withIdentifier: "goToShop", sender: self)
            }
        }
    }
}

extension DiscoverViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var shopCell = ShopsCollectionViewCell()
        if let tempCell = shopCollection.dequeueReusableCell(withReuseIdentifier: "reusableShopCell", for: indexPath) as? ShopsCollectionViewCell {
            tempCell.setParameters(shop: shops[indexPath.row])
            shopCell = tempCell
            highlightCell(shopCell)
        }
        return shopCell
    }
    
    
}
