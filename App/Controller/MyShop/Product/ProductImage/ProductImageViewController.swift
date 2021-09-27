import UIKit
import Parse

/**/
/*
class ProductImageViewController

DESCRIPTION
        This class is a UIViewController that controls MyStore.storyboard's ProductImage View.
 
AUTHOR
        Rahul Guni
 
DATE
        08/12/2021
 
*/
/**/

class ProductImageViewController: UIViewController {
    
    //IBOutlet Functions
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productImageLarge: UIImageView!
    @IBOutlet weak var setDisplayButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    //Controller Parameters
    private var displayImage: UIImage?          //current Image displayed
    private var index: Int?                     //index of the image in pager
    private var productMode: ProductMode?       //Renders buttons according to ProductMode enum
    
    private var displayPictureId: String?       //objectId of the default picture of current Product
    private var currentPictureId: String?       //objectId of the current picture of current Product
    
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
    
    /**/
    /*
    @IBAction func setDisplayPictureClick(_ sender: Any)

    NAME

            setDisplayPictureClick - Sets current picture to the default picture of product.

    DESCRIPTION

            This function queries the Product_Images table and changes the current display picture's isDefault boolean
            to false and changes current picture's isDefault boolean to true.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/12/2021

    */
    /**/
    
    @IBAction func setDisplayPictureClick(_ sender: Any) {
        //Remove current Display Picture
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().objectId, equalTo: self.displayPictureId!)
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                object![ShopIO.Product_Images().isDefault] = false
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
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    /* @IBAction func setDisplayPictureClick(_ sender: Any)*/
    
    
    @IBAction func editClick(_ sender: Any) {
    }
}


// MARK:- Display Functions
extension ProductImageViewController {
    
    //Function to render buttons if opened in edit mode
    private func loadForEdit(){
        loadForView()
        editButton.isHidden = false
        setDisplayButton.isHidden = false
    }
    
    //Function to render images to the view
    func loadForView(){
        productImage.isHidden = true
        productImageLarge.isHidden = false
        productImageLarge.image = displayImage
    }
    
    //Setter function to set index of current Image, passed on from previous View Controller (MyProductViewController)
    func setIndex(index: Int) {
        self.index = index
    }
    
    //Setter function to set productMode, passed on from previous View Controller (MyProductViewController)
    func setProductMode(productMode: ProductMode) {
        self.productMode = productMode
    }
    
    //Setter function to set image, passed on from previous View Controller (MyProductViewController)
    func setImage(displayImage: UIImage?) {
        self.displayImage = displayImage
    }
    
    //Getter function to get index of current Image
    func getIndex() -> Int {
        return self.index!
    }
    
    //Setter function to set current Product's display picture's objectId, passed on from previous View Controller (MyProductViewController)
    func setDisplayPic(objectId : String) {
        self.displayPictureId = objectId
    }
    
    //Setter function set objectId of current Image, passed on from previous View Controller (MyProductViewController)
    func setCurrentPictureId(objectId: String) {
        self.currentPictureId = objectId
    }
    
    /**/
    /*
    private func setDisplayPic()

    NAME

            setDisplayPic - Sets current picture to the default picture of product.

    DESCRIPTION

            This function queries the Product_Images table and changes current picture's isDefault boolean to true.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/12/2021

    */
    /**/
    
    private func setDisplayPic() {
        let query = PFQuery(className: ShopIO.Product_Images().tableName)
        query.whereKey(ShopIO.Product_Images().objectId, equalTo: self.currentPictureId!)
        query.getFirstObjectInBackground{(object, error) in
            if(object != nil) {
                object![ShopIO.Product_Images().isDefault] = true
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
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    /* private func setDisplayPic() */
}

