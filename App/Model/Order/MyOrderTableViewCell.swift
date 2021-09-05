//
//  MyOrderTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 9/4/21.
//

import UIKit
import Parse

class MyOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var requestedQuantity: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(orderItem: OrderItem){
        self.requestedQuantity.text = "Requested Quantity: " + String(orderItem.getQuantity())
        let query = PFQuery(className: "Product")
        query.whereKey("objectId", equalTo: orderItem.getProductId())
        query.getFirstObjectInBackground{(product, error) in
            if let product = product {
                let currProduct = Product(product: product)
                self.getProductImage(product: currProduct)
                self.productTitle.text = currProduct.getTitle()
                self.priceLabel.text = "Price: $" + String(currProduct.getPrice())
                if(orderItem.getQuantity() > currProduct.getQuantity()) {
                    self.requestedQuantity.textColor = UIColor.red
                }
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    
    func getProductImage(product: Product) {
        let query = PFQuery(className: "Product_Images")

        query.whereKey("productId", equalTo: product.getObjectId())
        query.whereKey("isDefault", equalTo: "True")
        
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                let productImage = object?.value(forKey: "productImage")
                let tempImage = productImage as! PFFileObject
                tempImage.getDataInBackground{(imageData: Data?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let imageData = imageData {
                        self.productImage.image = UIImage(data: imageData)
                    }
                }
            }
            else {
               print("No default picture")
            }
        }
    }
}
