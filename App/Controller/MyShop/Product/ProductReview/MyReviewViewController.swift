import UIKit
import Parse

/**/
/*
class MyReviewViewController

DESCRIPTION
        This class is a UIViewController that controls ProductReview.storyboard's MyProductReview View.
 
AUTHOR
        Rahul Guni
 
DATE
        09/11/2021
 
*/
/**/

class MyReviewViewController: UIViewController {

    //IBOutlet elements
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var reviewContent: UITextView!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateSlider: UISlider!
    
    //Controller parameters
    private var rating: Double = 5.0        //default rating
    private var currProduct: Product?       //current Product
    private var currRating: ProductReview?  //current Product's current Review
    
    private var forEdit: Bool = false       //determines whether the view is for edit or add.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDisplay()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "reloadReviews") {
            let destination = segue.destination as! ProductReviewViewController
            destination.updateRating(rating: self.currRating!)
        }
    }
    
}

//MARK:- Display Functions
extension MyReviewViewController {
    
    //Setter function to set up current Product, passed on from previous view controller (ProductReviewViewController)
    func setProduct(product: Product) {
        self.currProduct = product
    }
    
    //Setter function to set up current Rating, passed on from previous view controller (ProductReviewViewController)
    func setRating(rating: ProductReview) {
        self.currRating = rating
    }
    
    //Setter function to set up forEdit boolean, passed on from previous view controller (ProductReviewViewController)
    func setForEdit(bool: Bool) {
        self.forEdit = bool
    }
    
    /**/
    /*
    func setDisplay()

    NAME

           setDisplay - Sets User Interaction

    DESCRIPTION

            This function makes the IBOutlet elements user interaction enabled if the view is on edit mode.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    private func setDisplay() {
        productTitle.text = self.currProduct!.getTitle()
        if(self.forEdit) {
            reviewTitle.isUserInteractionEnabled = true
            reviewContent.isUserInteractionEnabled = true
            addReviewButton.isHidden = false
            rateSlider.isUserInteractionEnabled = true
            if let _ = self.currRating {
                setLabels()
                self.addReviewButton.setTitle("Update", for: .normal)
            }
        }
        else {
            setLabels()
        }
    }
    /* private func setDisplay()*/
    
    /**/
    /*
    func setLabels()

    NAME

           setLabels - Fills UILabels with Product Review details

    DESCRIPTION

            This function fills the labels with the data from currRating object.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    private func setLabels() {
        reviewTitle.text = self.currRating!.getTitle()
        rateLabel.text = "Rating: " + self.currRating!.getRatingAsString()
        reviewContent.text = self.currRating!.getContent()
        self.rateSlider.maximumValue = 5.0
        self.rateSlider.minimumValue = 1.0
        self.rateSlider.value = Float(self.currRating!.getRating())
    }
    /* private func setLabels()*/
    
    /**/
    /*
    func addReview()

    NAME

           addReview - Add a new ProductReview Object

    DESCRIPTION

            This function uploads a new review in the Product_Review table with data from UIText Fields.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    private func addReview(){
        let review = PFObject(className: ShopIO.Product_Review().tableName)
        review[ShopIO.Product_Review().productId] = self.currProduct!.getObjectId()
        review[ShopIO.Product_Review().title] = self.reviewTitle.text!
        review[ShopIO.Product_Review().content] = self.reviewContent.text!
        review[ShopIO.Product_Review().userId] = currentUser!.objectId!
        review[ShopIO.Product_Review().rating] = self.rating
        
        review.saveInBackground{(success, error) in
            if(success) {
                self.currRating = ProductReview(reviewObject: review)
                self.performSegue(withIdentifier: "reloadReviews", sender: self)
            }
            else {
                let alert = customNetworkAlert(title: "Unable to add review.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* private func addReview()*/
    
    /**/
    /*
    func updateReview()

    NAME

           updateReview - Updates the user's ProductReview Object

    DESCRIPTION

            This function first queries the Product_Review and updates the fetched object with current strings in the view's UITextFields.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/11/2021

    */
    /**/
    
    private func updateReview(){
        let query = PFQuery(className: ShopIO.Product_Review().tableName)
        query.whereKey(ShopIO.Product_Review().objectId, equalTo: self.currRating!.getObjectId())
        query.getFirstObjectInBackground{(review, error) in
            if let review = review {
                review[ShopIO.Product_Review().productId] = self.currProduct!.getObjectId()
                review[ShopIO.Product_Review().title] = self.reviewTitle.text!
                review[ShopIO.Product_Review().content] = self.reviewContent.text!
                review[ShopIO.Product_Review().userId] = currentUser!.objectId!
                review[ShopIO.Product_Review().rating] = self.rating
                
                self.currRating = ProductReview(reviewObject: review)
                
                review.saveInBackground{(success, error) in
                    if(success) {
                        self.performSegue(withIdentifier: "reloadReviews", sender: self)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to update review.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
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
    /* private func updateReview()*/
}

//MARK:- IBOutlet Functions
extension MyReviewViewController {
    
    //Action after Add Review button click
    @IBAction func addReviewClicked(_ sender: Any) {
        if(self.reviewTitle.text!.isEmpty || self.reviewContent.text!.isEmpty) {
            let alert = customNetworkAlert(title: "Missing Field Entry", errorString: "Please make sure you have filled out all the required fields. ")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if(self.addReviewButton.titleLabel!.text == "Update") {
                updateReview()
            }
            else if(self.addReviewButton.titleLabel!.text == "Add Review") {
                addReview()
            }
        }
    }
    
    //adjust current rating according to slider's value
    @IBAction func sliderChanged(_ sender: Any) {
        self.rateSlider.maximumValue = 5.0
        self.rateSlider.minimumValue = 1.0
        self.rateSlider.value = round(rateSlider.value)
        self.rating = Double(round(rateSlider.value))
        self.rateLabel.text = "Rating: " + String(self.rating)
    }
}
