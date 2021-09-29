import UIKit
import RealmSwift
import Parse
import SwipeCellKit

/**/
/*
class CartViewController

DESCRIPTION
        This class is a UIViewController that controls Cart.storyboard's initial view.
        It extends from SwipCellKit to make cells swipeable. Link:- https://github.com/SwipeCellKit/SwipeCellKit
 
AUTHOR
        Rahul Guni
 
DATE
        07/27/2021
 
*/
/**/

class CartViewController: UIViewController {

    //IBOutlet Elements
    @IBOutlet weak var myCartItems: UICollectionView!
    @IBOutlet weak var checkOut: UIButton!
    @IBOutlet weak var cartTotal: UILabel!
    
    //Controller Parameters
    private var myItems: [CartItem] = []                    //A list to hold all cart items
    private var currItem: CartItem?                         //selected cart item
    private var myProduct: Product?                         //selected cart item to Product object
    private var currProductImage: [ProductImage] = []       //selected cart item's product photos
    private var myCart: Cart?                               //Cart Object to upload to Order Table
    private var orderComplete: Bool = false                 //determines if order is complete
    
    //Declare a label to render in case there is no cart items.
    private let noCartItemsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
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
        checkItemsExist()
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
            destination.setFresh(bool: true)
        }
    }

    //Function to unwind the segue and reload view
    @IBAction func unwindToMyCartWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if(self.orderComplete) {
                    self.cartTotal.text = "Total"
                    let alert = customNetworkAlert(title: "Order Successful", errorString: "Your order has been successfully places. Please head over to my orders to know the status of your order.")
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.myCart = Cart(cartItems: self.myItems)
                    self.cartTotal.text = self.myCart!.getTotalAsString()
                }
                self.myCartItems.reloadData()
                self.checkItemsExist()
            }
        }
    }
}

//MARK:- IBOutlet Functions
extension CartViewController {
    
    //Action for check out button click, segue to CheckOutViewController.
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
    
    /**/
    /*
    private func checkProduct(_ myItem: CartItem)

    NAME

            checkProduct - Checks
     
    SYNOPSIS
           
            private func checkProduct(_ myItem: CartItem)
                myItem      --> CartItem object to perform Product query

    DESCRIPTION

            This function takes in the current cartItem object and performs a query in Products table using the item's productId.
            It updates the Product according to current data in the table in any case parameters such as price, quantity etc. is
            modified by the shop owner. At the same time, additional parameters of the item such as name, price, etc. are added
            to the object in realm database.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/27/2021

    */
    /**/
    
    private func checkProduct(_ myItem: CartItem){
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().objectId, equalTo: myItem.productId!)
        query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let _ = error {
                // The query failed
                try! self.realm.write{
                    self.realm.delete(myItem)
                }
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            else if let object = object {
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
            self.checkItemsExist()
        }
    }
    /* private func checkProduct(_ myItem: CartItem) */
    
    //setter function to set current order as complete to present success alert.
    func setOrderComplete(bool: Bool) {
        self.orderComplete = bool
    }
    
    //Function to render noCartItemsLabel
    private func checkItemsExist() {
        if(self.myItems.isEmpty){
            self.myCartItems.isHidden = true
            self.cartTotal.isHidden = true
            self.checkOut.isHidden = true
            self.view.backgroundColor = UIColor.lightGray
            noCartItemsLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            noCartItemsLabel.textAlignment = .center
            noCartItemsLabel.text = "Empty Cart"
            self.view.addSubview(noCartItemsLabel)
        }
        else {
            self.view.backgroundColor = UIColor.white
            self.myCartItems.isHidden = false
            self.cartTotal.isHidden = false
            self.checkOut.isHidden = false
            noCartItemsLabel.removeFromSuperview()
        }
    }
}

//MARK:- UICollectionViewDelegate
extension CartViewController: UICollectionViewDelegate {
    
    /**/
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)

    NAME

           collectionView - Action for cartItem object in CollectionView cell click.

    DESCRIPTION

            This function queries the Product of cartItem using its productId and segues to MyProductViewController after fetching the product images.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/27/2021

    */
    /**/
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currItem = myItems[indexPath.row]
        let productId = currItem?.productId!
        
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().objectId, equalTo: productId!)
        query.getFirstObjectInBackground{ (object: PFObject?, error: Error?) in
            if let _ = error {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            else if let object = object {
                self.myProduct = Product(product: object)
                //find product images and perform segue
                self.currProductImage.removeAll()
                let query = PFQuery(className: ShopIO.Product_Images().tableName)
                query.whereKey(ShopIO.Product_Images().productId, equalTo: self.currItem!.productId!)
                query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
                    if let objects = objects {
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
    /* func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) */
    
}

//MARK:- UICollectionViewDataSource
extension CartViewController: UICollectionViewDataSource {
    
    //function to return number of cartItem in UICollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myItems.count
    }
    
    //function to populate the CollectionView cell, from CartItemCollectionViewCell.swift
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
    
    //Function to render swipe cell action when a collectionview cell is swiped. It extends from SwipeCellKit.
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
                    self.checkItemsExist()
                }))
                self.present(alert, animated: true, completion: nil)
                
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")

            return [deleteAction]
    }
}

