import UIKit
import Parse

/**/
/*
class UpdateProductCollectionViewController
 
DESCRIPTION
        This class is a UICollectionViewController that controls UpdateProduct Storyboard View.
 
AUTHOR
        Rahul Guni
 
DATE
        08/06/2021
 
*/
/**/

private let reuseIdentifier = "reusableUpdateProductCell"

class UpdateProductCollectionViewController: UICollectionViewController {
    
    private var myProducts: [Product] = []                  //products of current shop
    private var currProduct: Product?                       //current Product
    private var currShop: Shop?                             //current Shop
    private var currProductImages: [ProductImage] = []      //current Product's images
    
    lazy var searchBar: UISearchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.hideKeyboardWhenTappedAround()
        //sort the list by quantity of the products.
        myProducts = myProducts.sorted(by:{$0.getQuantity() < $1.getQuantity()})
        
        //Add Search Bar
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
}

//MARK:- General Functions
extension UpdateProductCollectionViewController {
    
    //Setter function to set up current Products, passed on from previous view controller (MyInventoryViewController)
    func setProducts(products: [Product]) {
        self.myProducts = products
    }
    
    //Setter function to set up current Shop, passed on from previous view controller (MyInventoryViewController)
    func setShop(shop: Shop) {
        self.currShop = shop
    }
    
    //Function to replace product once updated, used in next view controller (MyProductViewController)
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
    }
    
    //Function to display label if no results is found from search
    private func noProductsFound() {
        self.view.backgroundColor = UIColor.lightGray
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        label.textAlignment = .center
        label.text = "No Products Found."
        self.view.addSubview(label)
    }
    
    /**/
    /*
    private func getProducts()

    NAME

           getProducts - Fetches for all products of current shop.

    DESCRIPTION

            This function queries the Product table from current shop's shopId/objectId. The Product objects are
            appended to the myProducts array and the collection view is reloaded.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/06/2021

    */
    /**/
    
    private func getProducts() {
        self.myProducts.removeAll()
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.whereKey(ShopIO.Product().shopId, equalTo: self.currShop!.getShopId())
        query.findObjectsInBackground{(products, error) in
            if let products = products {
                for product in products {
                    self.myProducts.append(Product(product: product))
                }
                self.collectionView.reloadData()
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func getProducts()*/
}

//MARK:- UICollectionViewDelegate
extension UpdateProductCollectionViewController {
    
    /**/
    /*
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)

    NAME

           collectionView - Action for Collectionview Cell click.

    DESCRIPTION

            This function records the current Product object in currProduct variable, queries the Product_Images
            table by currProduct's objectId and appends it to currProductImages array. Finally, a segue to
            MyProductViewController is performed.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/06/2021

    */
    /**/
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currProduct = myProducts[indexPath.row]
        currProductImages.removeAll()
        
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().productId, equalTo: currProduct!.getObjectId())
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
    /* override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) */
}

//MARK:- UICollectionViewDataSource
extension UpdateProductCollectionViewController {
    
    //Function for number of sections in CollectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //Function for number of items in CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myProducts.count
    }

    //function to set up CollectionViewCell, from UpdateCollectionViewCell.swift
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? UpdateProductCollectionViewCell {
            tempCell.setParameters(product: myProducts[indexPath.row])
            cell = tempCell
            highlightCell(cell)
        }
        return cell
    }
}

//MARK:- UISearchBarDelegate
extension UpdateProductCollectionViewController: UISearchBarDelegate {
    
    /**/
    /*
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)

    NAME

            searchBarSearchButtonClicked - Action for Search Bar

    DESCRIPTION

            This function searches the Product Table and renders the products that matches searched title.
            It uses regex to perform the search operation.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            08/06/2021

    */
    /**/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.myProducts.removeAll()
        self.dismissKeyboard()
        if(!searchBar.searchTextField.text!.isEmpty) {
            let query = PFQuery(className: ShopIO.Product().tableName)
            query.whereKey(ShopIO.Product().title, matchesRegex: ".*\(searchBar.searchTextField.text!).*")
            query.whereKey(ShopIO.Product().shopId, equalTo: self.currShop!.getShopId())
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
    /* func searchBarSearchButtonClicked(_ searchBar: UISearchBar) */
    
    //load all products if the search bar is cleared.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.getProducts()
        }
    }
    
}
