import UIKit
import Parse

/**/
/*
class SearchViewController

DESCRIPTION
        This class is a UIViewController that controls Search.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        09/14/2021
 
*/
/**/

class SearchViewController: UIViewController {
    
    //IBOutlet Functions
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTable: UITableView!
    
    //Controller Parameters
    private var searchProducts: [Product] = []              //list of all products from search
    private var currProductImage: [ProductImage] = []       //images of current product
    private var currProduct: Product?                       //selected product
    private var currShop: Shop?                             //shop of selected product
    private var currShopProducts: [Product] = []            //all products of currShop
    private var forShop: Bool = false                       //determines if search within a shop
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterChange(_:)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToProduct") {
            let destination = segue.destination as! MyProductViewController
            destination.setMyProduct(product: self.currProduct!)
            if(self.forShop) {
                destination.productMode = ProductMode.forMyShop
            }
            else {
                destination.productMode = ProductMode.forPublic
            }
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

//MARK:- IN+BOutlet Functions
extension SearchViewController {
    //Action for filter button click
    @IBAction func filterChange(_ sender: UIButton) {
        self.showFilterAlert()
    }
}

//MARK:- General Functions
extension SearchViewController {
    
    //setter function for forShop boolean, passed from previous view controller (MyStoreViewController)
    func setForShop(bool: Bool) {
        self.forShop = bool
    }
    
    //setter function for current shop, passed from previous view controller (MyStoreViewController)
    func setShop(shop: Shop) {
        self.currShop = shop
    }
    
    /**/
    /*
    private func showAlert(shopName: String)

    NAME

            showAlert - Presents alert options for current product.
     
    SYNOPSIS
           
            showAlert(shopName: String)
                shopName     --> shop name of the selected product to display in alert message

    DESCRIPTION

            This function presents choices for the selected product:- Product Detail and Shop Details.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func showAlert(shopName: String) {
        let alert = UIAlertController(title: "Product Details", message: "View the product or view shop directly..", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "\(self.currProduct!.getTitle())", style: .default, handler: {(action: UIAlertAction) in
            self.goToProduct()
        }))
        if(!self.forShop) {
            alert.addAction(UIAlertAction(title: "View \(shopName)", style: .default, handler: {(action: UIAlertAction) in
                self.goToShop()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /* private func showAlert(shopName: String)*/
    
    /**/
    /*
    private func goToProduct()

    NAME

           goToProduct - Performs segue to MyProductViewController

    DESCRIPTION

            This function first queries the Product_Images table to fetch images for selected product,
            appends them to currProductImage and segues to MyProductViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func goToProduct() {
        self.currProductImage.removeAll()
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().productId, equalTo: self.currProduct!.getObjectId())
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
    /* private func goToProduct()*/
    
    /**/
    /*
    private func goToShop()

    NAME

           goToShop - Performs segue to MyStoreViewController

    DESCRIPTION

            This function first queries the Shop table to fetch shop for selected product, then fetches product in
            Product for the shop and appends them to currShopProducts and finally segues to MyStoreViewController.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func goToShop() {
        self.currShopProducts.removeAll()
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: self.currProduct!.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.currShop = Shop(shop: shop)
                let productsQuery = PFQuery(className: ShopIO.Product().tableName)
                productsQuery.whereKey(ShopIO.Product().shopId, equalTo: self.currShop!.getShopId())
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
    /* private func goToShop()*/
    
    /**/
    /*
    private func showFilterAlert()

    NAME

           showFilterAlert - Presents alert in .form for filter

    DESCRIPTION

            This function presents the user with four options to sort the products: Quantity: High to low and low to high,
            and Price: High to low and low to high.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    private func showFilterAlert() {
        let alert = UIAlertController(title: "Sort Products", message: "Choose sort..", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Quantity: High to Low", style: .default, handler: {(action: UIAlertAction) in
            self.searchProducts = self.searchProducts.sorted(by:{$0.getQuantity() > $1.getQuantity()})
            self.resultsTable.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Quantity: Low to High", style: .default, handler: {(action: UIAlertAction) in
            self.searchProducts = self.searchProducts.sorted(by:{$0.getQuantity() < $1.getQuantity()})
            self.resultsTable.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Price: High to Low", style: .default, handler: {(action: UIAlertAction) in
            self.searchProducts = self.searchProducts.sorted(by:{$0.getPrice() > $1.getPrice()})
            self.resultsTable.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Price: Low to High", style: .default, handler: {(action: UIAlertAction) in
            self.searchProducts = self.searchProducts.sorted(by:{$0.getPrice() < $1.getPrice()})
            self.resultsTable.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /* private func showFilterAlert()*/
}

//MARK:- UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    
    /**/
    /*
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)

    NAME

            searchBarSearchButtonClicked - Action for search button click

    DESCRIPTION

            This function queries the Product Query using regular expressions to match the typed title to product title
            in the database. If the search is performed inside a shop, only current shop's products are rendered.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchProducts.removeAll()
        self.resultsTable.reloadData()
        self.dismissKeyboard()
        if(!searchBar.searchTextField.text!.isEmpty) {
            let query = PFQuery(className: ShopIO.Product().tableName)
            query.whereKey(ShopIO.Product().title, matchesRegex: ".*\(searchBar.searchTextField.text!).*")
            if(self.forShop) {
                query.whereKey(ShopIO.Product().shopId, equalTo: self.currShop!.getShopId())
            }
            query.findObjectsInBackground{(products, error) in
                if let products = products {
                    for product in products {
                        self.searchProducts.append(Product(product: product))
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.resultsTable.reloadData()
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
    /* func searchBarSearchButtonClicked(_ searchBar: UISearchBar)*/
}

//MARK:- UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    /**/
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

    NAME

            tableView - Action for tableview cell click

    DESCRIPTION

            This function first queries the Shop Table to fetch the selected Product's shop and presents alert from showAlert()

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/14/2021

    */
    /**/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currProduct = self.searchProducts[indexPath.row]
        let query = PFQuery(className: ShopIO.Shop().tableName)
        query.whereKey(ShopIO.Shop().objectId, equalTo: self.currProduct!.getShopId())
        query.getFirstObjectInBackground{(shop, error) in
            if let shop = shop {
                self.showAlert(shopName: Shop(shop: shop).getShopTitle())
            }
            else {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) */
}

//MARK:- UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    //function to return number of products after search
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchProducts.count
    }
    
    //function to populate serach table cells, from ProductSearchTableViewCell.swift
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableProductSearchCell", for: indexPath) as! ProductSearchTableViewCell
        cell.setParameters(product: self.searchProducts[indexPath.row], forShop: self.forShop)
        return cell
    }
}
