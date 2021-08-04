//
//  AddressCollectionViewCell.swift
//  App
//
//  Created by Rahul Guni on 8/2/21.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var fullAddress: UILabel!
    @IBOutlet weak var addressType: UILabel!
    
    func setParameters(address currAddress: Address, type : String) {
        var street: String?
        if(currAddress.getLine2() != nil && currAddress.getLine2() != "") {
            street = currAddress.getLine1()! + ", " + currAddress.getLine2()!
        }
        else{
            street = currAddress.getLine1()
        }
        self.streetAddress.text = street
        let full = currAddress.getCity()! + ", " + currAddress.getState()! + ", " + currAddress.getZip()!
        self.fullAddress.text = full
        self.addressType.text = "Type: " + type
    }
    
}
