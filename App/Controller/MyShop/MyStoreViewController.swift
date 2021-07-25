//
//  MyStoreView.swift
//  App
//
//  Created by Rahul Guni on 7/1/21.
//

import UIKit
import Parse


//MARK: - UIViewController
class MyStoreViewController: UIViewController {
    
    @IBOutlet weak var shopSlogan: UITextField!
    @IBOutlet weak var shopTitle: UITextField!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var noProductText: UITextField!
    @IBOutlet weak var addProduct: UIButton!
    @IBOutlet weak var productsCollection: UICollectionView!
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var editLabel: UILabel!
    
    //Build a shop model
    private var currShop : Shop?
    
    //a dictionary to store all products of the shop
    private var myProducts: [Product] = []
    //selected product
    private var currProduct: Product?
    //Editable switch variable
    private var forEdit: Bool = false
    //view mode for owner and customers
    private var forOwner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up products collection view
        productsCollection.delegate = self
        productsCollection.dataSource = self
        
        //set up edit field
        if(forOwner) {
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
        productsCollection.layer.borderWidth = 0.5
        productsCollection.layer.borderColor = UIColor.black.cgColor
        
        editSwitch.isOn = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "toAddProduct") {
            let destination = segue.destination as! AddProductViewController
            destination.setShop(shop: currShop)
        }
        if(segue.identifier! == "goToMyProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: currProduct!)
            destination.setEditMode(forEdit, forOwner)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyStoreWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.productsCollection.reloadData()
            }
        }
    }
    

    func fillMyProducts(productsList products: [Product]) {
        self.myProducts = products
    }
    
    func setShop(shop: Shop?){
        self.currShop = shop
    }
    
    func setOwner(_ bool: Bool) {
        if(bool) {
            self.forOwner = true
        }
        else {
            self.forOwner = false
        }
    }
    
    func hasProduct(_ bool: Bool) {
        self.addProduct.isHidden = bool
        self.noProductText.isHidden = bool
        self.productsCollection.isHidden = !bool
    }
    
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
    }
    
    @IBAction func editMode(_ sender: UISwitch) {
        if(editSwitch.isOn) {
            forEdit = true
        }
        else {
            forEdit = false
        }
    }
}

//MARK: - ColectionViewDelegate
extension MyStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currProduct = myProducts[indexPath.row]
        performSegue(withIdentifier: "goToMyProduct", sender: self)
    }
}

//MARK: - CollectionViewDatasource
extension MyStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myProducts.count
    }
    
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

