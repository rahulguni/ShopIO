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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        

        // Do any additional setup after loading the view.
        
        //sort the list by quantity of the products.
        myProducts = myProducts.sorted(by:{$0.getQuantity() < $1.getQuantity()})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "goToMyProduct" {
            let destination = segue.destination as! MyProductViewController
            destination.productMode = ProductMode.forUpdate
            destination.setMyProduct(product: currProduct!)
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
    
    func replaceProduct(with updateProduct: Product) {
        for product in myProducts {
            if product.getObjectId() == updateProduct.getObjectId() {
                product.setProduct(product: updateProduct)
            }
        }
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
        performSegue(withIdentifier: "goToMyProduct", sender: self)
    }
}
