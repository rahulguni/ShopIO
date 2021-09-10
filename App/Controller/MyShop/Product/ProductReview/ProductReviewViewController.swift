//
//  ProductReviewViewController.swift
//  App
//
//  Created by Rahul Guni on 9/10/21.
//

import UIKit

class ProductReviewViewController: UIViewController {
    
    private var ratings: [ProductReview] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for rating in ratings {
            print(rating.getRating())
        }
    }

}

//MARK:- General Functions
extension ProductReviewViewController {
    func setRatings(ratings: [ProductReview]) {
        self.ratings = ratings
    }
}
