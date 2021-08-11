//
//  MyStoreView.swift
//  App
//
//  Created by Rahul Guni on 7/1/21.
//

import UIKit
import Parse


//MARK: - UIViewController
class MyStoreViewController: UIViewController {
    
    @IBOutlet weak var shopSlogan: UITextField!
    @IBOutlet weak var shopTitle: UITextField!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var noProductText: UITextField!
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var productsCollection: UICollectionView!
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var editLabel: UILabel!
    
    //Build a shop model
    private var currShop : Shop?
    
    //a dictionary to store all products of the shop
    private var myProducts: [Product] = []
    //selected product
    private var currProduct: Product?
    
    private var productMode : ProductMode?
    
    //go to discover if only called from discover
    private var willExit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up products collection view
        productsCollection.delegate = self
        productsCollection.dataSource = self
        
        //set up edit field
        if(productMode == ProductMode.forMyShop) {
            editSwitch.isHidden = false
            editLabel.isHidden = false
            followButton.isHidden = true
            if(myProducts.count == 0) {
                hasProduct(false)
            }
            else {
                hasProduct(true)
            }
        }
        
        //Set up other buttons and labels
        modifyButton(button: addProduct)
        shopSlogan.text = currShop?.getShopSlogan()
        shopTitle.text = currShop?.getShopTitle()
        productsCollection.layer.borderWidth = 0.5
        productsCollection.layer.borderColor = UIColor.black.cgColor
        checkFollowed()
        
        editSwitch.isOn = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toAddProduct") {
            let destination = segue.destination as! AddProductViewController
            destination.setShop(shop: currShop)
        }
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: currProduct!)
            destination.setMyShop(shop: currShop!)
            destination.productMode = self.productMode
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(willExit == false) {
            performSegue(withIdentifier: "goToDiscover", sender: self)
        }
    }
    
    func setExit(_ bool: Bool) {
        self.willExit = bool
    }
}

extension MyStoreViewController {
    func fillMyProducts(productsList products: [Product]) {
        self.myProducts = products
    }
    
    func setShop(shop: Shop?){
        self.currShop = shop
    }
    
    func setForShop(_ productMode: ProductMode ) {
        self.productMode = productMode
    }
    
    private func hasProduct(_ bool: Bool) {
        self.addProduct.isHidden = bool
        self.noProductText.isHidden = bool
        self.productsCollection.isHidden = !bool
        self.editLabel.isHidden = !bool
        self.editSwitch.isHidden = !bool
    }
    
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
    }
    
    private func checkFollowed(){
        if(currentUser != nil) {
            let query = PFQuery(className: "Followings")
            query.whereKey("userId", equalTo: String(currentUser!.objectId!))
            query.whereKey("shopId", equalTo: currShop!.getShopId())
            query.getFirstObjectInBackground {(success, error) in
                if(success != nil) {
                    self.followButton.setTitle("Unfollow", for: .normal)
                }
            }
        }
    }
}

extension MyStoreViewController {
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyStoreWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.productsCollection.reloadData()
            }
        }
    }
    
    @IBAction func editMode(_ sender: UISwitch) {
        if(editSwitch.isOn) {
            self.productMode = ProductMode.forOwner
        }
        else {
            self.productMode = ProductMode.forMyShop
        }
    }
    
    @IBAction func followClicked(_ sender: Any) {
        if(currentUser != nil) {
            if(self.followButton.titleLabel!.text == "Follow") {
                let follower = PFObject(className: "Followings")
                follower["userId"] = currentUser!.objectId!
                follower["shopId"] = currShop!.getShopId()
                follower.saveInBackground {(success, error) in
                    if(success) {
                        self.followButton.setTitle("Unfollow", for: .normal)
                    }
                    else {
                        let alert = networkErrorAlert(title: "Network Error", errorString: "Error following this user. Please try later.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let unfollower = PFQuery(className: "Followings")
                unfollower.whereKey("userId", equalTo: String(currentUser!.objectId!))
                unfollower.whereKey("shopId", equalTo: currShop!.getShopId())
                unfollower.getFirstObjectInBackground{(obj, error) in
                    if(obj != nil) {
                        let alert = UIAlertController(title: "Are you sure you want to unfollow \(self.currShop!.getShopTitle())?", message: "Please select below", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Unfollow", comment: "Unfollow Button"), style: .default, handler: { _ in
                            obj!.deleteInBackground()
                            self.followButton.setTitle("Follow", for: .normal)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = networkErrorAlert(title: "Network Error", errorString: "Error unfollowing this user. Please try later.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else{
            performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
}

//MARK: - ColectionViewDelegate
extension MyStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currProduct = myProducts[indexPath.row]
        performSegue(withIdentifier: "goToMyProduct", sender: self)
    }
}

//MARK: - CollectionViewDatasource
extension MyStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var productCell = ProductsCollectionViewCell()
        if let tempCell = productsCollection.dequeueReusableCell(withReuseIdentifier: "ProductsReusableCell", for: indexPath) as? ProductsCollectionViewCell {
            tempCell.setParameters(Product: myProducts[indexPath.row])
            productCell = tempCell
            highlightCell(productCell)
        }
        return productCell
    }
}

