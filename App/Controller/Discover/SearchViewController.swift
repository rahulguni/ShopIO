//
//  SearchViewController.swift
//  App
//
//  Created by Rahul Guni on 9/14/21.
//

import UIKit
import Parse

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTable: UITableView!
    
    private var searchProducts: [Product] = []
    private var currProductImage: [ProductImage] = []
    private var currProduct: Product?
    private var currShop: Shop?
    private var currShopProducts: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        resultsTable.delegate = self
        resultsTable.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: self.currProduct!)
            destination.productMode = ProductMode.forPublic
            destination.setImages(myImages: currProductImage)
        }
        if(segue.identifier! == "goToShop") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: self.currShop!)
            destination.setForShop(ProductMode.forPublic)
            destination.fillMyProducts(productsList: self.currShopProducts)
        }
    }

}

//MARK:- General Functions
extension SearchViewController {
    private func showAlert() {
        let alert = UIAlertController(title: "Product Details", message: "View the product or view shop directly..", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "\(self.currProduct!.getTitle())", style: .default, handler: {(action: UIAlertAction) in
            self.goToProduct()
        }))
        alert.addAction(UIAlertAction(title: "View Shop", style: .default, handler: {(action: UIAlertAction) in
            self.goToShop()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func goToProduct() {
        self.currProductImage.removeAll()
        let query = PFQuery(className: "Product_Images")
        query.whereKey("productId", equalTo: self.currProduct!.getObjectId())
        query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) in
            if let _ = error {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            } else if let objects = objects {
                for object in objects {
                    let productImage = ProductImage(image: object)
                    self.currProductImage.append(productImage)
                }
            }
            self.performSegue(withIdentifier: "goToProduct", sender: self)
        }
    }
    
    private func goToShop() {
        self.currShopProducts.removeAll()
        let query = PFQuery(className: "Shop")
        query.whereKey("objectId", equalTo: self.currProduct!.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.currShop = Shop(shop: shop)
                let productsQuery = PFQuery(className: "Product")
                productsQuery.whereKey("shopId", equalTo: self.currShop!.getShopId())
                productsQuery.findObjectsInBackground{(products, error) in
                    if let products = products {
                        for product in products {
                            self.currShopProducts.append(Product(product: product))
                        }
                        self.performSegue(withIdentifier: "goToShop", sender: self)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchProducts.removeAll()
        self.dismissKeyboard()
        if(!searchBar.searchTextField.text!.isEmpty) {
            let query = PFQuery(className: "Product")
            query.whereKey("title", matchesText: searchBar.searchTextField.text!)
            query.findObjectsInBackground{(products, error) in
                if let products = products {
                    for product in products {
                        self.searchProducts.append(Product(product: product))
                    }
                    self.resultsTable.reloadData()
                }
                else{
                    let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK:- UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currProduct = self.searchProducts[indexPath.row]
        self.showAlert()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableProductSearchCell", for: indexPath) as! ProductSearchTableViewCell
        cell.setParameters(product: self.searchProducts[indexPath.row])
        return cell
    }
}
