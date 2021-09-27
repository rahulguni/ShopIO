import UIKit
import Parse

/**/
/*
class AddProductExtraViewController

DESCRIPTION
        This class is a UIViewController that controls AddProduct.storyboard's Extra View.
 
AUTHOR
        Rahul Guni
 
DATE
        07/17/2021
 
*/
/**/

class AddProductExtraViewController: UIViewController {
    
    //IBOutlet elements
    @IBOutlet weak var headerLabel: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var contents: UITextView!
    
    private var myProduct: Product?     //details of current Product
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        headerLabel.text = myProduct?.getTitle()
    }
}

//MARK:- IBOutlet Functions
extension AddProductExtraViewController {
    
    /**/
    /*
    @IBAction func saveButtonPressed(_ sender: UIButton)

    NAME

           saveButtonPressed - Action for Save Button Click

    DESCRIPTION

            This function updates the current Product's discount and content field in Product table, initially
            set to 0% and an empty string in previous view controller.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/17/2021

    */
    /**/
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if(discount.text!.isEmpty) {
            let alert = customNetworkAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let query = PFQuery(className: ShopIO.Product().tableName)
            query.whereKey(ShopIO.Product().objectId, equalTo: myProduct!.getObjectId())
            query.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
                if let _ = error {
                    // The query failed
                    let alert = customNetworkAlert(title: "Unable to save product details.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
                else if let object = object {
                    
                    if(self.discount.text != "") {
                        let discountAmount = Float(self.discount.text!)
                        if(discountAmount! > 100) {
                            let alert = customNetworkAlert(title: "Invalid Discount Percentage", errorString: "Discount percentage must be in the range of 0-100.")
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            object[ShopIO.Product().discount] = Float(self.discount!.text!)
                        }
                    }
                    else{
                        object[ShopIO.Product().discount] = Float(0.0)
                    }
                    object[ShopIO.Product().content] = self.contents.text
                    object.saveInBackground {(success, error) in
                        if(success) {
                            //go to main
                            self.performSegue(withIdentifier: "reloadEditShop", sender: self)
                            self.performSegue(withIdentifier: "reloadMyShop", sender: self)
                        }
                        else{
                            let alert = customNetworkAlert(title: "Error", errorString: "Failed to save.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    /* @IBAction func saveButtonPressed(_ sender: UIButton) */
}

//MARK:- Display Functions
extension AddProductExtraViewController {
    
    //setter function to set current product, passed on from previous view controller (AddProductViewController)
    func setProduct(product: Product?) {
        self.myProduct = product
    }
}
