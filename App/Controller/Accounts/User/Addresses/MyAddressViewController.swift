import UIKit
import Parse

/**/
/*
class MyAddressViewController

DESCRIPTION
        This class is a UIViewController that controls MyAddresses.storyboard view.
AUTHOR
        Rahul Guni
DATE
        08/02/2021
*/
/**/

class MyAddressViewController: UIViewController {
    
    //IbOutlet elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressCollection: UICollectionView!
    @IBOutlet weak var addNewAddressButton: UIButton!
    
    //Controller variables
    private var addresses: [String: Address] = [:]      //dictionary to separate address objects by their type (primary, shop, alternate)
    private var currAddress: Address?                   //selected address
    private var shopId: String?                         //shopId of shop Address
    private var forAddressEdit: forAddress?             //enum to load next view accordingly
    private var forOrder: Bool = false                  //if called from checkout to select ship address.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let name = currentUser!.value(forKey: ShopIO.User().fName) as! String
        self.titleLabel.text = "Hello \(name)"
        self.addresses.removeAll()
        addressCollection.delegate = self
        addressCollection.dataSource = self
        getAddresses()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToAddressEdit") {
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
    
    //Action for add address button click in top right.
    @IBAction func addNewAddressClicked(_ sender: Any) {
        self.forAddressEdit = forAddress.forAddNewShop
        self.performSegue(withIdentifier: "goToAddAddress", sender: self)
    }
}

//MARK:- Regular Functions
extension MyAddressViewController {
    
    //Function to get all addresses of current user.
    private func getAddresses() {
        getPrimaryAddress()
        getOtherAddresses()
        if(!forOrder) {
            getShopAddress()
        }
    }
    
    //Setter function to set forOrder boolean, only true if called from CheckOutViewController.
    func setForOrder(bool: Bool) {
        self.forOrder = bool
    }
    
    /**/
    /*
    private func getPrimaryAddress()

    NAME

            getPrimaryAddress - Gets user's primary address

    DESCRIPTION

            This function queries the Address table using current user's objectId and appends the user's primary address
            object to addresses dictionary with key as primary address.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/02/2021

    */
    /**/
    
    private func getPrimaryAddress() {
        let pQuery = PFQuery(className: ShopIO.Address().addressTableName)
        pQuery.whereKey(ShopIO.Address().userId, equalTo: currentUser!.objectId!)
        pQuery.whereKey(ShopIO.Address().isDefault, equalTo: true)
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
    /* private func getPrimaryAddress() */
    
    /**/
    /*
    private func getOtherAddresses()

    NAME

            getOtherAddresses - Gets user's other addresses except primary

    DESCRIPTION

            This function queries the Address table using current user's objectId and appends the addresses other than
            primary address to addresses dictionary with key as alternate address.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/02/2021

    */
    /**/
    
    private func getOtherAddresses() {
        let pQuery = PFQuery(className: ShopIO.Address().addressTableName)
        pQuery.whereKey(ShopIO.Address().userId, equalTo: currentUser!.objectId!)
        pQuery.whereKey(ShopIO.Address().isDefault, equalTo: false)
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
    /* private func getOtherAddresses() */
    
    /**/
    /*
    private func getShopAddress()

    NAME

            getShopAddress - Gets user's shop address

    DESCRIPTION

            This function queries the Shop_Address table using current user's objectId. First, Shop table is queried
            to find the user's shop and then Shop_Address table is queried using the shop's objectId. The address
            object is then appended to address dictionary with key Shop Address.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/02/2021

    */
    /**/
    
    private func getShopAddress(){
        let sQuery = PFQuery(className: ShopIO.Shop().tableName)
        sQuery.whereKey(ShopIO.Shop().userId, equalTo: currentUser!.objectId!)
        sQuery.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.shopId = shop.objectId!
                //find shop address in shop_address table
                let saQuery = PFQuery(className: ShopIO.Shop_Address().shopAddressTableName)
                saQuery.whereKey(ShopIO.Shop_Address().shopId, equalTo: shop.objectId!)
                saQuery.getFirstObjectInBackground{(address, error) in
                    if let address = address{
                        let tempAddress = Address(address: address)
                        self.addresses["Shop Address"] = tempAddress
                        self.shopId = address[ShopIO.Shop_Address().shopId] as? String
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
    /* private func getShopAddress() */

}


//MARK:- UICollectionViewDelegate
extension MyAddressViewController: UICollectionViewDelegate{
    
    /**/
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)

    NAME

            collectionView - Action for address cell click

    DESCRIPTION

            This function performs segue to next view controller according to the type of address selected.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/02/2021

    */
    /**/
    
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
    /* func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)*/
}

//MARK:- UICollectionViewDataSource
extension MyAddressViewController: UICollectionViewDataSource{
    
    //Function to load number of address objects in CollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addresses.count
    }
    
    //Function to populate CollectionView cells, from AddressCollectionView.swift
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


