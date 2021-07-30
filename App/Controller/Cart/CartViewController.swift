//
//  CartViewController.swift
//  App
//
//  Created by Rahul Guni on 7/27/21.
//

import UIKit
import RealmSwift
import Parse

class CartViewController: UIViewController {

    @IBOutlet weak var myCartItems: UICollectionView!
    @IBOutlet weak var checkOut: UIButton!
    
    //A list to hold all cart items
    private var myItems: [CartItem] = []
    private var currItem: CartItem?
    private var myProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCartItems.delegate = self
        myCartItems.dataSource = self
        
        modifyButton(button: checkOut)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //render all products
        myItems = []
        
        let realm = try! Realm()
        //let cart = Cart()
        
        if(currentUser != nil) {
            let myCartItems = realm.objects(CartItem.self)
            for item in myCartItems {
                if((item["userId"] as! String) == currentUser!.objectId) {
                    myItems.append(item)
                }
            }
            self.myCartItems.reloadData()
        }
        else {
            performSegue(withIdentifier: "goToSignIn", sender: self)
            myItems = []
            self.myCartItems.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            //destination.editAbleProduct(false, true)
            destination.setMyProduct(product: myProduct!)
        }
    }
}

extension CartViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = myItems[indexPath.row]
        let productId = currItem?.productId!
        
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: productId!)
        query.getFirstObjectInBackground{ (object: PFObject?, error: Error?) in
                if let error = error {
                    let alert = networkErrorAlert(title: "Could not load item.", errorString: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                } else if let object = object {
                    self.myProduct = Product(product: object)
                    self.performSegue(withIdentifier: "goToMyProduct", sender: self)
                }
        }
    }
}

extension CartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var itemCell = CartItemCollectionViewCell()
        if let tempCell = myCartItems.dequeueReusableCell(withReuseIdentifier: "reusableItemCell", for: indexPath) as? CartItemCollectionViewCell {
            tempCell.setParameters(product: myItems[indexPath.row])
            itemCell = tempCell
            highlightCell(itemCell)
        }
        return itemCell
    }
}
