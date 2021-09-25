import UIKit
import Parse

/**/
/*
class ProductReviewViewController

DESCRIPTION
        This class is a UIViewController that controls ProductReview.storyboard's initial View.
AUTHOR
        Rahul Guni
DATE
        09/10/2021
*/
/**/

class ProductReviewViewController: UIViewController {
    
    @IBOutlet weak var productReviewTable: UITableView!
    @IBOutlet weak var addReviewButton: UIButton!
    
    private var ratings: [ProductReview] = []   //All ratings for current Product
    private var currProduct: Product?           //current Product
    private var currRating: ProductReview?      //selected review
    private var forEdit: Bool = false           //if true, present next view on edit mode. True only if review already done for currProduct

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

    //action for add review button click
    @IBAction func addReviewClicked(_ sender: Any) {
        self.forEdit = true
        checkReview()
    }
    
}

//MARK:- General Functions
extension ProductReviewViewController {
    
    //Setter function to set up current product's ratings, passed on from previous view controller (MyProductViewController)
    func setRatings(ratings: [ProductReview]) {
        self.ratings = ratings
    }
    
    //Setter function to set up current product, passed on from previous view controller (MyProductViewController)
    func setProduct(product: Product) {
        self.currProduct = product
    }
    
    //Setter function to update current product's ratings, passed on from next view controller (MyReviewViewController)
    func updateRating(rating: ProductReview) {
        var counter = 0
        //Replace review if edited, else append a new one to the ratings array.
        var reviewFound: Bool = false
        for currRating in ratings {
            if currRating.getObjectId() == rating.getObjectId() {
                ratings.remove(at: counter)
                ratings.insert(rating, at: 0)
                reviewFound = true
            }
            counter += 1
        }
        if(!reviewFound) {
            self.ratings.insert(rating, at: 0)
        }
    }
    
    /**/
    /*
    private func checkProductInOrder()

    NAME

            checkProductInOrder

    DESCRIPTION

            This function checks if the product has been purchased by the user. If true, add review button is displayed otherwise the button is hidden by default.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/10/2021

    */
    /**/
    
    private func checkProductInOrder(){
        let query = PFQuery(className: ShopIO.Order().tableName)
        query.whereKey(ShopIO.Order().userId, equalTo: currentUser!.objectId!)
        query.whereKey(ShopIO.Order().shopId, equalTo: currProduct!.getShopId())
        query.whereKey(ShopIO.Order().fulfilled, equalTo: true)
        query.findObjectsInBackground{(orders, error) in
            if let orders = orders {
                for order in orders {
                    let currOrder = Order(order: order)
                    let query = PFQuery(className: ShopIO.Order_Item().tableName)
                    query.whereKey(ShopIO.Order_Item().orderId, equalTo: currOrder.getObjectId())
                    query.whereKey(ShopIO.Order_Item().productId, equalTo: self.currProduct!.getObjectId())
                    query.getFirstObjectInBackground{(product, error) in
                        if let _ = product {
                            //render add review button only if order has been placed
                            self.addReviewButton.isHidden = false
                        }
                    }
                }
            }
        }
    }
    /* private func checkProductInOrder() */
    
    /**/
    /*
    private func checkReview()

    NAME

            checkReview

    DESCRIPTION

            This function checks if the product has already been reviewd by the user. If true, next view is loaded as edit review view rather than add review.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/10/2021

    */
    /**/
    
    private func checkReview() {
        let query = PFQuery(className: ShopIO.Product_Review().tableName)
        query.whereKey(ShopIO.Product_Review().userId, equalTo: currentUser!.objectId!)
        query.whereKey(ShopIO.Product_Review().productId, equalTo: currProduct!.getObjectId())
        query.getFirstObjectInBackground {(productReview, error) in
            if let productReview = productReview {
                //review found, make review updateable
                self.forEdit = true
                self.currRating = ProductReview(reviewObject: productReview)
            }
            self.performSegue(withIdentifier: "goToMyReview", sender: self)
        }
    }
    /* private func checkReview()*/
}

//MARK:- UITableViewDelegate
extension ProductReviewViewController: UITableViewDelegate {
    
    //go to MyReviewViewController when a tableview cell is clicked.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currRating = self.ratings[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.forEdit = false
        self.performSegue(withIdentifier: "goToMyReview", sender: self)
    }
}

//MARK:- UITableViewDataSource
extension ProductReviewViewController: UITableViewDataSource {
    
    //function to render the number of Rating Objects in TableView Cells.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratings.count
    }
    
    //function to populate the tableView Cells, from ProductReviewTableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableReviewCell", for: indexPath) as! ProductReviewTableViewCell
        cell.setParameters(productReviw: self.ratings[indexPath.row])
        return cell
    }
}
