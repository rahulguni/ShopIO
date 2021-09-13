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
    @IBOutlet weak var mapButton: UIButton!
    
    //Build a shop model
    private var currShop : Shop?
    
    //a dictionary to store all products of the shop
    private var myProducts: [Product] = []
    //selected product
    private var currProduct: Product?
    
    private var productMode : ProductMode?
    
    private var currProductImage: [ProductImage] = []
    
    private var shopLocation: CLLocationCoordinate2D?
    
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
        let shopImagecover = currShop?.getShopImage()
        let tempImage = shopImagecover
        tempImage!.getDataInBackground{(imageData: Data?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let imageData = imageData {
                self.shopImage.image = UIImage(data: imageData)
            }
        }
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
        
        if(segue.identifier! == "goToMaps") {
            let destination = segue.destination as! MapViewController
            destination.setLocation(coordinates: self.shopLocation!)
            destination.setShop(shop: self.currShop!)
        }
        
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: currProduct!)
            destination.setMyShop(shop: currShop!)
            destination.setImages(myImages: currProductImage)
            destination.productMode = self.productMode
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /*Add later
         if(willExit == false) {
            performSegue(withIdentifier: "goToDiscover", sender: self)
        }*/
    }
    
    func setExit(_ bool: Bool) {
        self.willExit = bool
    }
}

//MARK: - Regular Functions
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

//MARK: - IBOutlet Functions
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
    
    @IBAction func mapButtonClicked(_ sender: Any) {
        let query = PFQuery(className: "Shop_Address")
        query.whereKey("shopId", equalTo: self.currShop!.getShopId())
        query.getFirstObjectInBackground{(shopAddress, error) in
            if let shopAddress = shopAddress {
                let address = Address(address: shopAddress)
                //find CLLocationDegrees of Shop Address
                self.shopLocation = CLLocationCoordinate2D(latitude: address.getGeoPoints().latitude, longitude: address.getGeoPoints().longitude)
                self.performSegue(withIdentifier: "goToMaps", sender: self)
            }
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
                        let alert = customNetworkAlert(title: "Network Error", errorString: "Error following this user. Please try later.")
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
                        let alert = customNetworkAlert(title: "Network Error", errorString: "Error unfollowing this user. Please try later.")
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
        //find product images and perform segue
        currProductImage.removeAll()
        let query = PFQuery(className: "Product_Images")
        query.whereKey("productId", equalTo: currProduct!.getObjectId())
        query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    let productImage = ProductImage(image: object)
                    self.currProductImage.append(productImage)
                }
            }
            self.performSegue(withIdentifier: "goToMyProduct", sender: self)
        }
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

