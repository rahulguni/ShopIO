//
//  AddShop.swift
//  App
//
//  Created by Rahul Guni on 6/29/21.
//

import UIKit
import Parse

class AddShopViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var shopSlogan: UITextField!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subTitleLabel: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    private var myShop: Shop?
    var forEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(forEdit){
            loadEditShop()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //function to make address controller store address in shop database for shops
        if(segue.identifier! == "toAddress") {
            let destination = segue.destination as! AddressViewController
            destination.forShop = true
            destination.shopId = myShop!.getShopId()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if (shopName.text!.isEmpty){
            let alert = networkErrorAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        
        else {
            if(myShop == nil) {
                saveShop()
            }
            else {
                updateShop()
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        self.showAlert()
    }
    
    func setShop(shop myShop: Shop) {
        self.myShop = myShop
    }
    
    private func loadEditShop(){
        titleLabel.text = "Welcome"
        subTitleLabel.text = "Modify the fields below and press update."
        let shopName = myShop?.getShopTitle()
        let shopSlogan = myShop?.getShopSlogan()
        self.shopName.text = shopName
        self.shopSlogan.text = shopSlogan
        self.continueButton.setTitle("Update", for: .normal)
    }
    
    private func saveShop(){
        let shop = PFObject(className: "Shop")
        shop["userId"] = currentUser!.objectId!
        shop["title"] = shopName.text
        shop["slogan"] = shopSlogan.text
        
        /*let imageData = shopImage.image!.jpegData(compressionQuality: 0.1)!
        print(type(of: imageData))
        let shopImage = PFFileObject(data: imageData)
        shop["shopImage"] = shopImage*/
        
        shop.saveInBackground{(success, error) in
            if(success) {
                self.myShop = Shop(shop: shop)
                self.performSegue(withIdentifier: "toAddress", sender: self)
            }
            else{
                let alert = networkErrorAlert(title: "Network Error", errorString: "Could not save shop at this time. Please try again.")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func updateShop() {
        let query = PFQuery(className: "Shop")
        query.getObjectInBackground(withId: myShop!.getShopId()) { (shop: PFObject?, error: Error?) in
            if let myShop = shop {
                myShop["title"] = self.shopName.text
                myShop["slogan"] = self.shopSlogan.text
                myShop.saveInBackground{(success, error) in
                    if(success) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        let alert = networkErrorAlert(title: "Error Updating", errorString: "Could not update shop at this time  Please try again.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK:- UIImagePickerViewDelegate.
    //Show alert to selected the media source type.
    private func showAlert() {
        
        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true) { [weak self] in
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            //Setting image to your image view
            self?.shopImage.image = image
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

