//
//  ProductImageViewController.swift
//  App
//
//  Created by Rahul Guni on 8/12/21.
//

import UIKit
import Parse

class ProductImageViewController: UIViewController {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productImageLarge: UIImageView!
    @IBOutlet weak var setDisplayButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    
    private var displayImage: UIImage?
    private var index: Int?
    private var productMode: ProductMode?
    
    private var displayPictureId: String?
    private var currentPictureId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productImage.image = displayImage
        
        if(productMode == ProductMode.forPublic || productMode == ProductMode.forMyShop || productMode == ProductMode.forCart) {
            loadForView()
        }
        
        if(productMode == ProductMode.forOwner || productMode == ProductMode.forUpdate) {
            loadForEdit()
        }
        
    }
}

// MARK:- IBOutlet Functions
extension ProductImageViewController {
    @IBAction func setDisplayPictureClick(_ sender: Any) {
        //Remove current Display Picture
        let query = PFQuery(className: "Product_Images")
        query.whereKey("objectId", equalTo: self.displayPictureId!)
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                object!["isDefault"] = false
                object?.saveInBackground {(success, error) in
                    if(success) {
                        //Set current Picture as Display Picture
                        self.setDisplayPic()
                    }
                    else {
                        let alert = customNetworkAlert(title: "Unable to set Display Picture", errorString: "There was an error setting up your display pic. Please try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                print("No Default Image.")
            }
        }
    }
    
    
    @IBAction func editClick(_ sender: Any) {
    }
}


// MARK:- Display Functions
extension ProductImageViewController {
    func loadForEdit(){
        loadForView()
        editButton.isHidden = false
        setDisplayButton.isHidden = false
    }
    
    func loadForView(){
        productImage.isHidden = true
        productImageLarge.isHidden = false
        productImageLarge.image = displayImage
    }
    
    
    
    func setIndex(index: Int) {
        self.index = index
    }
    
    func setProductMode(productMode: ProductMode) {
        self.productMode = productMode
    }
    
    func setImage(displayImage: UIImage?) {
        self.displayImage = displayImage
    }
    
    func getIndex() -> Int {
        return self.index!
    }
    
    func setDisplayPic(objectId : String) {
        self.displayPictureId = objectId
    }
    
    func setCurrentPictureId(objectId: String) {
        self.currentPictureId = objectId
    }
    
    func setDisplayPic() {
        let query = PFQuery(className: "Product_Images")
        query.whereKey("objectId", equalTo: self.currentPictureId!)
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                object!["isDefault"] = true
                object?.saveInBackground {(success, error) in
                    if(success) {
                        let alert = customNetworkAlert(title: "Display Picture Changed", errorString: "This picture has been set as your current display picture.")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Error Changing Display Pciture", errorString: "There was an error setting display picture. Please try again later.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                print("Product Not found.")
            }
            
        }
    }
}

