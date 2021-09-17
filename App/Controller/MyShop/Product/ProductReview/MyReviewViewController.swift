//
//  MyReviewViewController.swift
//  App
//
//  Created by Rahul Guni on 9/11/21.
//

import UIKit
import Parse

class MyReviewViewController: UIViewController {

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var reviewContent: UITextView!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateSlider: UISlider!
    
    private var rating: Double = 5.0
    private var currProduct: Product?
    private var currRating: ProductReview?
    
    private var forEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDisplay()
        self.dismissKeyboard()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "reloadReviews") {
            let destination = segue.destination as! ProductReviewViewController
            destination.addRating(rating: self.currRating!)
        }
    }
    
}

//MARK:- Display Functions
extension MyReviewViewController {
    
    func setProduct(product: Product) {
        self.currProduct = product
    }
    
    func setRating(rating: ProductReview) {
        self.currRating = rating
    }
    
    func setForEdit(bool: Bool) {
        self.forEdit = bool
    }
    
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
    
    private func setLabels() {
        reviewTitle.text = self.currRating!.getTitle()
        rateLabel.text = "Rating: " + self.currRating!.getRatingAsString()
        reviewContent.text = self.currRating!.getContent()
        self.rateSlider.maximumValue = 5.0
        self.rateSlider.minimumValue = 1.0
        self.rateSlider.value = Float(self.currRating!.getRating())
    }
    
    private func addReview(){
        let review = PFObject(className: "Product_Review")
        review["productId"] = self.currProduct!.getObjectId()
        review["title"] = self.reviewTitle.text!
        review["content"] = self.reviewContent.text!
        review["userId"] = currentUser!.objectId!
        review["rating"] = self.rating
        
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
    
    private func updateReview(){
        let query = PFQuery(className: "Product_Review")
        query.whereKey("objectId", equalTo: self.currRating!.getObjectId())
        query.getFirstObjectInBackground{(review, error) in
            if let review = review {
                review["productId"] = self.currProduct!.getObjectId()
                review["title"] = self.reviewTitle.text!
                review["content"] = self.reviewContent.text!
                review["userId"] = currentUser!.objectId!
                review["rating"] = self.rating
                
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
}

//MARK:- IBOutlet Functions
extension MyReviewViewController {
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
    
    @IBAction func sliderChanged(_ sender: Any) {
        self.rateSlider.maximumValue = 5.0
        self.rateSlider.minimumValue = 1.0
        self.rateSlider.value = round(rateSlider.value)
        self.rating = Double(round(rateSlider.value))
        self.rateLabel.text = "Rating: " + String(self.rating)
    }
}
