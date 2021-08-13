//
//  ImageCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/12/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    func setImage(image currImage: UIImage) {
        self.productImage.image = currImage
    }
}
