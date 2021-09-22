//
//  UpdateProductCollectionViewController.swift
//  App
//
//  Created by Rahul Guni on 8/6/21.
//

import UIKit
import Parse

private let reuseIdentifier = "reusableUpdateProductCell"

class UpdateProductCollectionViewController: UICollectionViewController {
    
    private var myProducts: [Product] = []
    private var currProduct: Product?
    private var currShop: Shop?
    private var currProductImages: [ProductImage] = []
    
    lazy var searchBar: UISearchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        

        // Do any additional setup after loading the view.
        
        //sort the list by quantity of the products.
        myProducts = myProducts.sorted(by:{$0.getQuantity() < $1.getQuantity()})
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        if(myProducts.count == 0) {
            noProductsFound()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "goToMyProduct" {
            let destination = segue.destination as! MyProductViewController
            destination.productMode = ProductMode.forUpdate
            destination.setMyProduct(product: currProduct!)
            destination.setMyShop(shop: currShop!)
            destination.setImages(myImages: currProductImages)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToUpdateProductsWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func setProducts(products: [Product]) {
        self.myProducts = products
    }
    
    func setShop(shop: Shop) {
        self.currShop = shop
    }
    
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
    }
    
    private func noProductsFound() {
        self.view.backgroundColor = UIColor.lightGray
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        label.textAlignment = .center
        label.text = "No Products Found."
        self.view.addSubview(label)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myProducts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? UpdateProductCollectionViewCell {
            tempCell.setParameters(product: myProducts[indexPath.row])
            cell = tempCell
            highlightCell(cell)
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currProduct = myProducts[indexPath.row]
        currProductImages.removeAll()
        
        let query = PFQuery(className: "Product_Images")
        query.whereKey("productId", equalTo: currProduct!.getObjectId())
        query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
            if let objects = objects {
                for object in objects {
                    let productImage = ProductImage(image: object)
                    self.currProductImages.append(productImage)
                }
            }
            self.performSegue(withIdentifier: "goToMyProduct", sender: self)
        }
    }
}

extension UpdateProductCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.myProducts.removeAll()
        self.dismissKeyboard()
        if(!searchBar.searchTextField.text!.isEmpty) {
            let query = PFQuery(className: "Product")
            query.whereKey("title", hasPrefix: searchBar.searchTextField.text!)
            query.whereKey("shopId", equalTo: self.currShop!.getShopId())
            query.findObjectsInBackground{(products, error) in
                if let products = products {
                    for product in products {
                        self.myProducts.append(Product(product: product))
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
                else{
                    let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
