import UIKit
import Parse
import MapKit

/**/
/*
class DiscoverViewController

DESCRIPTION
        This class is a UIViewController that controls Discover.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        07/24/2021
 
*/
/**/

class DiscoverViewController: UIViewController, CLLocationManagerDelegate {

    //IBOutlet Elements
    @IBOutlet weak var shopCollection: UICollectionView!
    @IBOutlet weak var followedShops: UICollectionView!
    
    private var followedList: [Shop] = []               //a list to store followed Shops
    private var shops: [Shop] = []                      //a list to store all shops
    private var currShop: Shop?                         //to record selected shop
    private var currProducts: [Product] = []            //to transfer product list to shop view
    private var locationManager: CLLocationManager!
    private var radius: Double = 25                   //default radius 25 miles to search for shops around
    private var sliderAlert: UIAlertController?         //Alert for location Filter.
    
    //Declare a label to render in case there is no followed shops.
    private let noFollowedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
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
                //self.getAllShops()
                self.getFollowedShops()
            }
        }
        self.checkFollowedShopsExist()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        shopCollection.delegate = self
        shopCollection.dataSource = self
        shopCollection.isHidden = true
        followedShops.delegate = self
        followedShops.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchClicked(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(currentUser != nil) {
            getFollowedShops()
        }
        getShopsWithinRadius()
        self.checkFollowedShopsExist()
    }
}

//MARK:- IBOutlet Functions
extension DiscoverViewController {
    
    //Action for search Button Click, segue to SearchViewController.
    @IBAction func searchClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
    /**/
    /*
    @IBAction func editDistance(_ sender: Any)

    NAME

           editDistance - Presents an alert to choose shop distance filter.

    DESCRIPTION

            This function gets all shops within the set radius and displays them on the collectionview.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    @IBAction func editDistance(_ sender: Any) {
        //get the Slider values from UserDefaults
        let defaultSliderValue = Float(round(self.radius))
        
        //create the Alert message with extra return spaces
        sliderAlert = UIAlertController(title: "Edit distance to view more shops", message: "Radius: \(Int(self.radius)) miles\n\n", preferredStyle: .alert)
        
        //create a Slider and fit within the extra message spaces
        //add the Slider to a Subview of the sliderAlert
        let slider = UISlider(frame:CGRect(x: 10, y: 100, width: 250, height: 20))
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = defaultSliderValue
        slider.isContinuous = true
        slider.tintColor = UIColor.blue
        sliderAlert!.view.addSubview(slider)
        
        //Update message when Slider value changed
        slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
       // slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        
        //OK button action
        let sliderAction = UIAlertAction(title: "OK", style: .default, handler: { (result : UIAlertAction) -> Void in
            UserDefaults.standard.set(slider.value, forKey: "sliderValue")
            self.getShopsWithinRadius()
        })
        
        //Cancel button action
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        //Add buttons to sliderAlert
        sliderAlert!.addAction(sliderAction)
        sliderAlert!.addAction(cancelAction)
        
        //present the sliderAlert message
        self.present(sliderAlert!, animated: true, completion: nil)
    }
    /* @IBAction func editDistance(_ sender: Any) */
    
    //Action for slider value change, record it in radius and set labels
    @objc func sliderValueDidChange(_ slider :UISlider!){
        self.radius = Double(round(slider.value))
        self.sliderAlert!.message = "Radius: \(Int(self.radius)) miles\n\n"
    }
}

//MARK:- Display Functions
extension DiscoverViewController {
    
    /**/
    /*
    private func getShopsWithinRadius()

    NAME

            getShopsWithinRadius - Fetches shops in the set radius

    DESCRIPTION

            This function first checks user's current location and gets all shops within the set radius and displays
            them on the collectionview.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    private func getShopsWithinRadius() {
        self.shops.removeAll()
        //get user's current location first
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingLocation()
            if let location : CLLocation = locationManager.location {
                self.getShopsWithInLocation(location: location.coordinate)
            }
            else{
                let alert = customNetworkAlert(title: "Unable to get current location.", errorString: "Please ensure location services are turned on.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getShopsWithinRadius()*/
    
    /**/
    /*
    private func getShopsWithInLocation(location: CLLocationCoordinate2D)

    NAME

            getShopsWithInLocation- Get all shops within location
     
    SYNOPSIS
           
            getShopsWithInLocation(location: CLLocationCoordinate2D)
                location      --> a CLLocationCoordinate2d object to filter shops according to this geopoint

    DESCRIPTION

            This function takes in current user's location and fetches shops in Shop table with Parse's geopoints filter
            feature. The shops are appended to shops array. link:  https://docs.parseplatform.org/ios/guide/#geopoints

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    private func getShopsWithInLocation(location: CLLocationCoordinate2D){
        self.shops.removeAll()
        let shopQuery = PFQuery(className: ShopIO.Shop().tableName)
        shopQuery.whereKey(ShopIO.Shop().userId, notEqualTo: currentUser?.objectId ?? "")
        shopQuery.whereKey(ShopIO.Shop().geoPoints, nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude), withinKilometers: self.radius)
        shopQuery.findObjectsInBackground{(shops, error) in
            if let shops = shops{
                for shop in shops {
                    let newShop = Shop(shop: shop)
                    let productQuery = PFQuery(className: ShopIO.Product().tableName)
                    productQuery.whereKey(ShopIO.Product().shopId, equalTo: newShop.getShopId())
                    productQuery.getFirstObjectInBackground{(object: PFObject?, error: Error?) in
                        if(object != nil) {
                            self.shops.append(newShop)
                        }
                        DispatchQueue.main.async {
                            self.shopCollection.reloadData()
                        }
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            self.shopCollection.isHidden = false
        }
    }
    /* private func getShopsWithInLocation(location: CLLocationCoordinate2D)*/
    
    /**/
    /*
    private func getFollowedShops()

    NAME

           getFollowedShops - Fetch current user's Followed shops.

    DESCRIPTION

            This function queries the Followings table to get the shopIds of all shops current user follows. Then, the Shop
            table is queried using the same shopIds and rendered on collectionview.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    private func getFollowedShops(){
        self.followedList.removeAll()
        let query = PFQuery(className: ShopIO.Followings().tableName)
        if(currentUser != nil) {
            query.whereKey(ShopIO.Followings().userId, equalTo: currentUser!.objectId!)
            query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) in
                if let objects = objects {
                    for object in objects {
                        self.followedShops.backgroundColor = UIColor.white
                        let followedShop = PFQuery(className: ShopIO.Shop().tableName)
                        followedShop.order(byAscending: ShopIO.Shop().createdAt)
                        followedShop.getObjectInBackground(withId: object[ShopIO.Followings().shopId] as! String){(shop, error) in
                            if shop != nil {
                                let newShop = Shop(shop: shop)
                                self.followedList.append(newShop)
                            }
                            else {
                                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                                self.present(alert, animated: true, completion: nil)
                            }
                            self.followedShops.reloadData()
                            self.checkFollowedShopsExist()
                        }
                    }
                }
                else {
                    self.followedList.removeAll()
                    
                }
                self.followedShops.reloadData()
            }
        }
    }
    /* private func getFollowedShops() */
    
    //Function to render noFollowedLabel if orders do not exist.
    private func checkFollowedShopsExist() {
        if(self.followedList.isEmpty){
            self.followedShops.backgroundColor = UIColor.lightGray
            noFollowedLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            noFollowedLabel.textAlignment = .center
            noFollowedLabel.text = "No Followed Shops."
            self.followedShops.backgroundView = noFollowedLabel
        }
        else {
            self.view.backgroundColor = UIColor.white
            self.followedShops.backgroundView = nil
            noFollowedLabel.removeFromSuperview()
        }
    }
}

//MARK:- UICollectionViewDelegate
extension DiscoverViewController: UICollectionViewDelegate{
    
    /**/
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)

    NAME

            collectionView - Action for collection view cell click.
     
    SYNOPSIS
           
            getAllUserMessages(id userId: String, forShop: Bool)
                userId      --> objectId of user if messages fetched for user, objectId of shop if messages fetched for shop.
                forShop     --> Determines if messages to be fetched is for user or shop

    DESCRIPTION

            This function fetched all products for the selected shop in Product table and segues to MyStoreViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/24/2021

    */
    /**/
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == shopCollection {
            currShop = shops[indexPath.row]
        }
        else{
            currShop = followedList[indexPath.row]
        }
        currProducts.removeAll()
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().shopId, equalTo: currShop!.getShopId())
        query.order(byAscending: ShopIO.Product().title)
        query.findObjectsInBackground{(products: [PFObject]?, error: Error?) in
            if let _ = error {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
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
    /* func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) */
}

//MARK:- UICollectionViewDataSource
extension DiscoverViewController: UICollectionViewDataSource{
    
    //Function to return number of collectionview cells.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == shopCollection){
            return shops.count
        }
        else{
            return followedList.count
        }
    }
    
    //Function to populate collectionview cell, from either ShopsCollectionViewCell.swift or FollowedShopCollectionViewCell.swift
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == shopCollection) {
            var shopCell = ShopsCollectionViewCell()
            if let tempCell = shopCollection.dequeueReusableCell(withReuseIdentifier: "reusableShopCell", for: indexPath) as? ShopsCollectionViewCell {
                let userCoordinate = CLLocation(latitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)
                let shopCoordinate = CLLocation(latitude: shops[indexPath.row].getGeoPoints().latitude, longitude: shops[indexPath.row].getGeoPoints().longitude)
                let distanceInMeters = userCoordinate.distance(from: shopCoordinate) // result is in meters
                tempCell.setParameters(shop: shops[indexPath.row])
                tempCell.setShopDistance(distance: distanceInMeters)
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
