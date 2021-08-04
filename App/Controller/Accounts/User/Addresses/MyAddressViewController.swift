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
    
    var addresses: [String: Address] = [:]
    var currAddress: Address?
    var forShop: Bool = false
    
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
            destination.forEdit = true
            destination.addressId = currAddress!.getObjectId()
            destination.forShopEdit = forShop
        }
    }
    
    private func getAddresses() {
        getShopAddress()
        getPrimaryAddress()
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
                //write error cases
                self.performSegue(withIdentifier: "goToAddAddress", sender: self)
            }
            self.addressCollection.reloadData()
        }
    }
    
    private func getShopAddress(){
        let sQuery = PFQuery(className: "Shop")
        sQuery.whereKey("userId", equalTo: currentUser!.objectId!)
        sQuery.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                //find shop address in shop_address table
                let saQuery = PFQuery(className: "Shop_Address")
                saQuery.whereKey("shopId", equalTo: shop.objectId!)
                saQuery.getFirstObjectInBackground{(address, error) in
                    if let address = address{
                        let tempAddress = Address(address: address)
                        self.addresses["Shop Address"] = tempAddress
                    }
                    else{
                        //write error cases
                    }
                    self.addressCollection.reloadData()
                }
            }
            else {
                //error getting shops
                print("No shops")
            }
        }
    }

}

extension MyAddressViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currAddress = Array(addresses)[indexPath.row].value
        if(Array(addresses)[indexPath.row].key == "Shop Address") {
            forShop = true
        }
        performSegue(withIdentifier: "goToAddressEdit", sender: self)
    }
    
}

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


