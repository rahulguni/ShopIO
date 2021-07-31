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
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCartItems.delegate = self
        myCartItems.dataSource = self
        
        modifyButton(button: checkOut)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(currentUser == nil) {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //render all products
        myItems.removeAll()
        
        //let cart = Cart()
        
        if(currentUser != nil) {
            let myCartItems = realm.objects(CartItem.self)
            for item in myCartItems {
                if((item["userId"] as! String) == currentUser!.objectId) {
                    //check product before viewing cart in case the shop has modified its product
                    checkProduct(item)
                }
            }
        }
        else {
            myItems.removeAll()
        }
        self.myCartItems.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forMyCart
        }
        
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            //destination.editAbleProduct(false, true)
            destination.setMyProduct(product: myProduct!)
            destination.productMode = forProducts.forCart
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyCartWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewWillAppear(true)
            }
        }
    }
    
    private func checkProduct(_ myItem: CartItem){
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: myItem.productId!)
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // The query failed
                print(error.localizedDescription)
            } else if let object = object {
                let currProduct = Product(product: object)
                try! self.realm.write {
                    myItem.productTitle = currProduct.getTitle()
                    myItem.price = currProduct.getPrice()
                    myItem.discount = currProduct.getDiscountAmount()
                    //check if the total quantity left is less than cart quantity. If so, update cart quantity.
                    if(myItem.quantity! > currProduct.getQuantity()) {
                        myItem.quantity = currProduct.getQuantity()
                    }
                }
                self.myItems.append(myItem)
            }
            self.myCartItems.reloadData()
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
