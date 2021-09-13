//
//  DiscoverViewController.swift
//  App
//
//  Created by Rahul Guni on 7/24/21.
//

import UIKit
import Parse
import MapKit

class DiscoverViewController: UIViewController, CLLocationManagerDelegate {

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
    //default radius 25 miles to search for shops around
    private var locationManager: CLLocationManager!
    private var radius: Double = 25
    private var sliderAlert: UIAlertController?
    
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
        if(currentUser != nil) {
            getFollowedShops()
        }
        getShopsWithinRadius()
    }
}

//MARK:- IBOutlet Functions
extension DiscoverViewController {
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
    
    @objc func sliderValueDidChange(_ slider :UISlider!){
        self.radius = Double(round(slider.value))
        self.sliderAlert!.message = "Radius: \(Int(self.radius)) miles\n\n"
    }
}

//MARK:- Display Functions
extension DiscoverViewController {
    
    func getShopsWithinRadius() {
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
                print("no location")
            }
        }
    }
    
    func getShopsWithInLocation(location: CLLocationCoordinate2D){
        self.shops.removeAll()
        let shopQuery = PFQuery(className: "Shop")
        shopQuery.whereKey("userId", notEqualTo: currentUser!.objectId!)
        shopQuery.whereKey("geoPoints", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude), withinKilometers: self.radius)
        shopQuery.findObjectsInBackground{(shops, error) in
            if let shops = shops{
                for shop in shops {
                    let newShop = Shop(shop: shop)
                    let productQuery = PFQuery(className: "Product")
                    productQuery.whereKey("shopId", equalTo: newShop.getShopId())
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
                print(error.debugDescription)
            }
            self.shopCollection.isHidden = false
        }
    }
    
    func getFollowedShops(){
        self.followedList.removeAll()
        let query = PFQuery(className: "Followings")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) in
            if let objects = objects {
                for object in objects {
                    let followedShop = PFQuery(className: "Shop")
                    followedShop.order(byAscending: "createdAt")
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
                
            }
            self.followedShops.reloadData()
        }
    }
}

//MARK:- UICollectionViewDelegate
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

//MARK:- UICollectionViewDataSource
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
