import UIKit
import Parse

/**/
/*
class MyStoreViewController

DESCRIPTION
        This class is a UIViewController that controls MyStore.storyboard's MyStore view.
 
AUTHOR
        Rahul Guni
 
DATE
        07/01/2021
 
*/
/**/

//MARK: - UIViewController
class MyStoreViewController: UIViewController {
    
    //IBOutlet elements
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
    
    //controller parameters
    private var currShop : Shop?                                //current Shop
    private var myProducts: [Product] = []                      //All products of current Shop
    private var currProduct: Product?                           //selected product
    private var productMode : ProductMode?                      //productMode enum to render next view accordingly
    private var currProductImage: [ProductImage] = []           //Images of selected Product
    private var shopLocation: CLLocationCoordinate2D?           //current Shop's geolocations
    private var willExit: Bool = true                           //go to discover if only called from discover
    
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
        
        if(segue.identifier! == "goToSearch") {
            let destination = segue.destination as! SearchViewController
            destination.setForShop(bool: true)
            destination.setShop(shop: self.currShop!)
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

//MARK: - Regular Functions
extension MyStoreViewController {
    
    //setter function to set all products of current Shop, passed on from previous view Controllers
    func fillMyProducts(productsList products: [Product]) {
        self.myProducts = products
    }
    
    //setter function to set current Shop, passed on from previous view Controllers
    func setShop(shop: Shop?){
        self.currShop = shop
    }
    
    //setter function to set productMode for Product, passed on from previous view Controllers
    func setForShop(_ productMode: ProductMode ) {
        self.productMode = productMode
    }
    
    //Function to set up labels according to myProducts array size. If zero, render add new product button.
    private func hasProduct(_ bool: Bool) {
        self.addProduct.isHidden = bool
        self.noProductText.isHidden = bool
        self.productsCollection.isHidden = !bool
        self.editLabel.isHidden = !bool
        self.editSwitch.isHidden = !bool
    }
    
    //replace product in myProducts with updated product, passed on from next view controller (MyProductViewController)
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
    }
    
    /**/
    /*
    private func checkFollowed()

    NAME

           checkFollowed - Checks if current user has followed the shop

    DESCRIPTION

            This function queries the followings table and changes the follow button's label to unfollow if the shop is already followed.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/01/2021

    */
    /**/
    
    private func checkFollowed(){
        if(currentUser != nil) {
            let query = PFQuery(className: ShopIO.Followings().tableName)
            query.whereKey(ShopIO.Followings().userId, equalTo: String(currentUser!.objectId!))
            query.whereKey(ShopIO.Followings().shopId, equalTo: currShop!.getShopId())
            query.getFirstObjectInBackground {(success, error) in
                if(success != nil) {
                    self.followButton.setTitle("Unfollow", for: .normal)
                }
            }
        }
    }
    /* private func checkFollowed() */
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
    
    //Switch edit mode if UISwitch is changed
    @IBAction func editMode(_ sender: UISwitch) {
        if(editSwitch.isOn) {
            self.productMode = ProductMode.forOwner
        }
        else {
            self.productMode = ProductMode.forMyShop
        }
    }
    
    /**/
    /*
    @IBAction func mapButtonClicked(_ sender: Any)

    NAME

           mapButtonClicked - Action for map button click.

    DESCRIPTION

            This function first fetches current Shop's geolocation from Shop's Address and segues to MapViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/01/2021

    */
    /**/
    
    @IBAction func mapButtonClicked(_ sender: Any) {
        let query = PFQuery(className: ShopIO.Shop_Address().shopAddressTableName)
        query.whereKey(ShopIO.Shop_Address().shopId, equalTo: self.currShop!.getShopId())
        query.getFirstObjectInBackground{(shopAddress, error) in
            if let shopAddress = shopAddress {
                let address = Address(address: shopAddress)
                //find CLLocationDegrees of Shop Address
                self.shopLocation = CLLocationCoordinate2D(latitude: address.getGeoPoints().latitude, longitude: address.getGeoPoints().longitude)
                self.performSegue(withIdentifier: "goToMaps", sender: self)
            }
        }
    }
    /* @IBAction func mapButtonClicked(_ sender: Any) */
    
    /**/
    /*
    @IBAction func followClicked(_ sender: Any)

    NAME

           followClicked - Action for follow button click.

    DESCRIPTION

            If the button's label is follow, previously set from checkFollowed function, then a new entry is added to Followings table.
            If the label is unfollow, a query matching shop's objectId and user's objectId will be removed from the table.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/01/2021

    */
    /**/
    
    @IBAction func followClicked(_ sender: Any) {
        if(currentUser != nil) {
            if(self.followButton.titleLabel!.text == "Follow") {
                let follower = PFObject(className: ShopIO.Followings().tableName)
                follower[ShopIO.Followings().userId] = currentUser!.objectId!
                follower[ShopIO.Followings().shopId] = currShop!.getShopId()
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
                let unfollower = PFQuery(className: ShopIO.Followings().tableName)
                unfollower.whereKey(ShopIO.Followings().userId, equalTo: String(currentUser!.objectId!))
                unfollower.whereKey(ShopIO.Followings().shopId, equalTo: currShop!.getShopId())
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
    /* @IBAction func followClicked(_ sender: Any)  */
}

//MARK: - ColectionViewDelegate
extension MyStoreViewController: UICollectionViewDelegate {
    
    /**/
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)

    NAME

            collectionView - Action for current Product cell click

    DESCRIPTION

            This function fetches all the pictures of current Product in Product_Images table and appends them to currProductImages
            array before segue to MyProductViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/01/2021

    */
    /**/
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currProduct = myProducts[indexPath.row]
        //find product images and perform segue
        currProductImage.removeAll()
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().productId, equalTo: currProduct!.getObjectId())
        query.order(byDescending: ShopIO.Product_Images().updatedAt)
        query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
            if let _ = error {
                // Log details of the failure
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            } else if let objects = objects {
                for object in objects {
                    let productImage = ProductImage(image: object)
                    self.currProductImage.append(productImage)
                }
            }
            self.performSegue(withIdentifier: "goToMyProduct", sender: self)
        }
    }
    /* func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)*/
}

//MARK: - CollectionViewDatasource
extension MyStoreViewController: UICollectionViewDataSource {
    
    //Function to return number of products in CollectionViewCell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myProducts.count
    }
    
    //Function to populate the collection View cell, from "ProductsCollectionViewCell.swift"
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

