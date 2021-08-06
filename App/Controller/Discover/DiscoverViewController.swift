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
    @IBOutlet weak var followedShops: UICollectionView!
    
    //a list to store followed Shops
    private var followedList: [Shop] = []
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
            destination.setForShop(ProductMode.forPublic)
            destination.setExit(false)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToDiscoverWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.followedList.removeAll()
                self.followedShops.reloadData()
                self.getFollowedShops()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        shopCollection.delegate = self
        shopCollection.dataSource = self
        shopCollection.isHidden = true
        followedShops.delegate = self
        followedShops.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.followedList.removeAll()
        self.shops.removeAll()
        if(currentUser != nil) {
            getFollowedShops()
        }
        getAllShops()
    }
    
    func getAllShops(){
        //can add to viewdidappear if reload after each view
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
            self.shopCollection.isHidden = false
        }
    }
    
    func getFollowedShops(){
        let query = PFQuery(className: "Followings")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) in
            if let objects = objects {
                for object in objects {
                    let followedShop = PFQuery(className: "Shop")
                    followedShop.getObjectInBackground(withId: object["shopId"] as! String){(shop, error) in
                        if shop != nil {
                            let newShop = Shop(shop: shop)
                            self.followedList.append(newShop)
                        }
                        else {
                            print("No Shop in Store")
                        }
                        self.followedShops.reloadData()
                    }
                }
            }
            else {
                self.followedList.removeAll()
                self.followedShops.reloadData()
            }
        }
    }
}

extension DiscoverViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == shopCollection {
            currShop = shops[indexPath.row]
        }
        else{
            currShop = followedList[indexPath.row]
        }
        currProducts.removeAll()
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
        if(collectionView == shopCollection){
            return shops.count
        }
        else{
            return followedList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == shopCollection) {
            var shopCell = ShopsCollectionViewCell()
            if let tempCell = shopCollection.dequeueReusableCell(withReuseIdentifier: "reusableShopCell", for: indexPath) as? ShopsCollectionViewCell {
                tempCell.setParameters(shop: shops[indexPath.row])
                shopCell = tempCell
                highlightCell(shopCell)
            }
            return shopCell
        }
        else {
            var shopCell = FollowedShopCollectionViewCell()
            if let tempCell = followedShops.dequeueReusableCell(withReuseIdentifier: "reusableFollowedShops", for: indexPath) as? FollowedShopCollectionViewCell {
                tempCell.setParameters(shop: followedList[indexPath.row])
                shopCell = tempCell
                highlightCell(shopCell)
            }
            return shopCell
        }
        
    }
    
    
}
