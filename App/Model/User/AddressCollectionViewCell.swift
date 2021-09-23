import UIKit

/**/
/*
class AddressCollectionViewCell

DESCRIPTION
        This class is a UICollectionViewCell class that makes up the cells for Address Collection view in MyAddressController.
AUTHOR
        Rahul Guni
DATE
        08/02/2021
*/
/**/

class AddressCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var fullAddress: UILabel!
    @IBOutlet weak var addressType: UILabel!
    
    /**/
    /*
    func setParameters(address currAddress: Address, type : String)

    NAME

            setParameters - Sets the parameter for Address Collection View Cell.

    SYNOPSIS

            setParameters(address currAddress: Address, type : String)
                currAddress      --> An address object to fill in the labels with correct data
                type             --> Type of address to be displayed (eg. Shop Address, Primary Address and Alternate Addresses)

    DESCRIPTION

            This function takes an object from the Address model and fills in the labels according to the data. The string 'type' is passed on from the controller according to the address type.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/02/2021

    */
    /**/
    
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
    /*func setParameters(address currAddress: Address, type : String)*/
    
}
