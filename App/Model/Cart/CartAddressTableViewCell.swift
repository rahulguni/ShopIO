//
//  CartAddressTableViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/25/21.
//

import UIKit

class CartAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAddress(address: String) {
        self.addressLabel.text = address
    }

}
