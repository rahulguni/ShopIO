//
//  MyAddressViewController.swift
//  App
//
//  Created by Rahul Guni on 8/2/21.
//

import UIKit
import Parse

class MyAddressViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressCollection: UICollectionView!
    @IBOutlet weak var addNewAddressButton: UIButton!
    
    private var addresses: [String: Address] = [:]
    private var currAddress: Address?
    private var shopId: String?
    private var forAddressEdit: forAddress?
    private var forOrder: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let name = currentUser!.value(forKey: "fName") as! String
        self.titleLabel.text = "Hello \(name)"
        self.addresses.removeAll()
        addressCollection.delegate = self
        addressCollection.dataSource = self
        getAddresses()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToAddressEdit") {
            let destination = segue.destination as! AddressViewController
            if let currAddress = self.currAddress {
                destination.setAddressId(addressId: currAddress.getObjectId())
            }
            destination.setEditMode(editMode: self.forAddressEdit!)
            if let shopId = self.shopId {
                destination.setShopId(shopId: shopId)
            }
        }
        
        if(segue.identifier! == "goToCheckOut") {
            let destination = segue.destination as! CheckOutViewController
            destination.setAddressId(address: currAddress!.getObjectId())
        }
        
        if(segue.identifier! == "goToAddAddress") {
            let destination = segue.destination as! AddressViewController
            destination.setEditMode(editMode: self.forAddressEdit!)
        }
    }
    
}

//MARK:- IBOutlet Functions
extension MyAddressViewController {
    @IBAction func addNewAddressClicked(_ sender: Any) {
        self.forAddressEdit = forAddress.forAddNewShop
        performSegue(withIdentifier: "goToAddAddress", sender: self)
    }
}

//MARK:- Regular Functions
extension MyAddressViewController {
    private func getAddresses() {
        getPrimaryAddress()
        getOtherAddresses()
        if(!forOrder) {
            getShopAddress()
        }
    }
    
    func setForOrder(bool: Bool) {
        self.forOrder = bool
    }
    
    private func getPrimaryAddress() {
        let pQuery = PFQuery(className: "Address")
        pQuery.whereKey("userId", equalTo: currentUser!.objectId!)
        pQuery.whereKey("isDefault", equalTo: true)
        pQuery.getFirstObjectInBackground{(address, error) in
            if let address = address{
                let tempAddress = Address(address: address)
                self.addresses["Primary Address"] = tempAddress
            }
            else{
                self.forAddressEdit = forAddress.forPrimary
                self.performSegue(withIdentifier: "goToAddAddress", sender: self)
            }
            self.addressCollection.reloadData()
        }
    }
    
    private func getOtherAddresses() {
        let pQuery = PFQuery(className: "Address")
        pQuery.whereKey("userId", equalTo: currentUser!.objectId!)
        pQuery.whereKey("isDefault", equalTo: false)
        pQuery.findObjectsInBackground{(addresses, error) in
            if let addresses = addresses{
                var counter = 1
                for address in addresses {
                    let tempAddress = Address(address: address)
                    self.addresses["Alternate " + String(counter)] = tempAddress
                    counter += 1
                }
            }
            else{
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            self.addressCollection.reloadData()
        }
    }
    
    private func getShopAddress(){
        let sQuery = PFQuery(className: "Shop")
        sQuery.whereKey("userId", equalTo: currentUser!.objectId!)
        sQuery.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.shopId = shop.objectId!
                //find shop address in shop_address table
                let saQuery = PFQuery(className: "Shop_Address")
                saQuery.whereKey("shopId", equalTo: shop.objectId!)
                saQuery.getFirstObjectInBackground{(address, error) in
                    if let address = address{
                        let tempAddress = Address(address: address)
                        self.addresses["Shop Address"] = tempAddress
                        self.shopId = address["shopId"] as? String
                        self.addressCollection.reloadData()
                    }
                    else {
                        self.forAddressEdit = forAddress.forShop
                        self.performSegue(withIdentifier: "goToAddressEdit", sender: self)
                    }
                }
            }
        }
    }

}


//MARK:- UICollectionViewDelegate
extension MyAddressViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currAddress = Array(addresses)[indexPath.row].value
        if(!forOrder) {
            if(Array(addresses)[indexPath.row].key == "Shop Address") {
                self.forAddressEdit = forAddress.forShopEdit
            }
            else{
                self.forAddressEdit = forAddress.forEdit
            }
            performSegue(withIdentifier: "goToAddressEdit", sender: self)
        }
        else {
            performSegue(withIdentifier: "goToCheckOut", sender: self)
        }
    }
    
}

//MARK:- UICollectionViewDataSource
extension MyAddressViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var addressCell = AddressCollectionViewCell()
        if let tempCell = addressCollection.dequeueReusableCell(withReuseIdentifier: "reusableAddressCell", for: indexPath) as? AddressCollectionViewCell {
            let type = Array(addresses)[indexPath.row].key
            let address = Array(addresses)[indexPath.row].value
            tempCell.setParameters(address: address, type: type)
            addressCell = tempCell
            highlightCell(addressCell)
        }
        return addressCell
    }
    
    
}


