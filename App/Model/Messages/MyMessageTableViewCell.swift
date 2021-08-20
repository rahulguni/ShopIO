//
//  MyMessageTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/20/21.
//

import UIKit
import Parse

class MyMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(displayImage: UIImage, message: String) {
        makePictureRounded(picture: self.displayImage)
        self.displayImage.image = displayImage
        self.message.text = message
    }
    
    func setCellForSender() {
        self.displayImage.isHidden = true
        self.message.textAlignment = .right
        self.message.backgroundColor = UIColor.white
    }

}
