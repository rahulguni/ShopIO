//
//  ProductReviewViewController.swift
//  App
//
//  Created by Rahul Guni on 9/10/21.
//

import UIKit
import Parse

class ProductReviewViewController: UIViewController {
    
    @IBOutlet weak var productReviewTable: UITableView!
    @IBOutlet weak var addReviewButton: UIButton!
    
    private var ratings: [ProductReview] = []
    private var currProduct: Product?
    private var currRating: ProductReview?
    private var forEdit: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productReviewTable.delegate = self
        productReviewTable.dataSource = self
        
        checkProductInOrder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyReview") {
            let destination = segue.destination as! MyReviewViewController
            destination.setProduct(product: self.currProduct!)
            if let currRating = self.currRating {
                destination.setRating(rating: currRating)
            }
            destination.setForEdit(bool: self.forEdit)
        }
    }
    
    //Function to unwind the segue and reload table cells
    @IBAction func unwindToProductReviewWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.productReviewTable.reloadData()
            }
        }
    }

    @IBAction func addReviewClicked(_ sender: Any) {
        self.forEdit = true
        checkReview()
    }
    
}

//MARK:- General Functions
extension ProductReviewViewController {
    func setRatings(ratings: [ProductReview]) {
        self.ratings = ratings
    }
    
    func setProduct(product: Product) {
        self.currProduct = product
    }
    
    private func checkProductInOrder(){
        let query = PFQuery(className: "Order")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.whereKey("fulfilled", equalTo: true)
        query.findObjectsInBackground{(orders, error) in
            if let orders = orders {
                for order in orders {
                    let currOrder = Order(order: order)
                    self.findProduct(orderId: currOrder.getObjectId())
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    private func findProduct(orderId: String) {
        let query = PFQuery(className: "Order_Item")
        query.whereKey("orderId", equalTo: orderId)
        query.whereKey("productId", equalTo: self.currProduct!.getObjectId())
        query.getFirstObjectInBackground{(product, error) in
            if let _ = product {
                //render add review button only if order has been placed
                self.addReviewButton.isHidden = false
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    private func checkReview() {
        let query = PFQuery(className: "Product_Review")
        query.whereKey("userId", equalTo: currentUser!.objectId!)
        query.whereKey("productId", equalTo: currProduct!.getObjectId())
        query.getFirstObjectInBackground {(productReview, error) in
            if let productReview = productReview {
                //review found, make review updateable
                self.forEdit = true
                self.currRating = ProductReview(reviewObject: productReview)
            }
            self.performSegue(withIdentifier: "goToMyReview", sender: self)
        }
    }
}

//MARK:- UITableViewDelegate
extension ProductReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currRating = self.ratings[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.forEdit = false
        self.performSegue(withIdentifier: "goToMyReview", sender: self)
    }
}

//MARK:- UITableViewDataSource
extension ProductReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableReviewCell", for: indexPath) as! ProductReviewTableViewCell
        cell.setParameters(productReviw: self.ratings[indexPath.row])
        return cell
    }
}
