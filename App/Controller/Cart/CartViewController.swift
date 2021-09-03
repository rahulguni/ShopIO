//
//  CartViewController.swift
//  App
//
//  Created by Rahul Guni on 7/27/21.
//

import UIKit
import RealmSwift
import Parse
import SwipeCellKit

class CartViewController: UIViewController {

    @IBOutlet weak var myCartItems: UICollectionView!
    @IBOutlet weak var checkOut: UIButton!
    @IBOutlet weak var cartTotal: UILabel!
    
    //A list to hold all cart items
    private var myItems: [CartItem] = []
    private var currItem: CartItem?
    private var myProduct: Product?
    private var currProductImage: [ProductImage] = []
    private var myCart: Cart?
    
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
        if(segue.identifier! == "toSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forMyCart
        }
        
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            //destination.editAbleProduct(false, true)
            destination.setMyProduct(product: myProduct!)
            destination.productMode = ProductMode.forCart
            destination.setImages(myImages: currProductImage)
        }
        
        if(segue.identifier! == "goToCheckOut") {
            let destination = segue.destination as! CheckOutViewController
            destination.setCart(cart: self.myCart!)
            destination.setItems(items: self.myItems)
        }
    }

    //Function to unwind the segue and reload view
    @IBAction func unwindToMyCartWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.cartTotal.text = "Total"
                let alert = customNetworkAlert(title: "Order Successful", errorString: "Your order has been successfully places. Please head over to my orders to know the status of your order.")
                self.present(alert, animated: true, completion: nil)
                self.myCartItems.reloadData()
            }
        }
    }
}

//MARK:- IBOutlet Functions
extension CartViewController {
    @IBAction func checkOutButtonClick(_ sender: Any) {
        //continue forming the cart to put it in orders database and push it to next view
        if self.myCart != nil && self.myCart?.getTotal() != 0 {
            self.performSegue(withIdentifier: "goToCheckOut", sender: self)
        }
        else {
            let alert = customNetworkAlert(title: "Empty Cart!", errorString: "Make sure your cart is not empty before checking out.")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK:- Display Function
extension CartViewController {
    private func checkProduct(_ myItem: CartItem){
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: myItem.productId!)
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // The query failed
                print(error.localizedDescription)
                try! self.realm.write{
                    self.realm.delete(myItem)
                }
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
            self.myCart = Cart(cartItems: self.myItems)
            self.cartTotal.text = self.myCart!.getTotalAsString()
            self.myCartItems.reloadData()
        }
    }
}

//MARK:- UICollectionViewDelegate
extension CartViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = myItems[indexPath.row]
        let productId = currItem?.productId!
        
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: productId!)
        query.getFirstObjectInBackground{ (object: PFObject?, error: Error?) in
            if let error = error {
                let alert = customNetworkAlert(title: "Could not load item.", errorString: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            } else if let object = object {
                self.myProduct = Product(product: object)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: "Product_Images")
                query.whereKey("productId", equalTo: self.currItem!.productId!)
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
    }
    
}

//MARK:- UICollectionViewDataSource
extension CartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var itemCell = CartItemCollectionViewCell()
        if let tempCell = myCartItems.dequeueReusableCell(withReuseIdentifier: "reusableItemCell", for: indexPath) as? CartItemCollectionViewCell {
            tempCell.setParameters(product: myItems[indexPath.row])
            itemCell = tempCell
            itemCell.delegate = self
            highlightCell(itemCell)
            itemCell.delegate = self
        }
        return itemCell
    }
    
}

extension CartViewController: SwipeCollectionViewCellDelegate{
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                let deleteItem = self.myItems[indexPath.row]
                let alert = UIAlertController(title: "Are you sure you want to remove this item from cart?", message: "Please select below", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Remove button"), style: .default, handler: { _ in
                    do {
                        try self.realm.write{
                            self.realm.delete(deleteItem)
                            self.myItems.remove(at: indexPath.row)
                        }
                    }catch {
                        print("error deleting category")
                    }
                    self.myCart = Cart(cartItems: self.myItems)
                    self.cartTotal.text = self.myCart!.getTotalAsString()
                    self.myCartItems.reloadData()
                    
                }))
                self.present(alert, animated: true, completion: nil)
                
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")

            return [deleteAction]
    }
}

