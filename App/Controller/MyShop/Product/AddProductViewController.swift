//
//  AddProductViewController.swift
//  App
//
//  Created by Rahul Guni on 7/17/21.
//

import UIKit
import Parse
import ImagePicker

class AddProductViewController: UIViewController{
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var summaryField: UITextView!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    private var myShop: Shop?
    private var myProduct: Product?
    private var myProductPhotos: [UIImage] = [/*UIImage.init(named: "Shopio")!, UIImage.init(named: "Shopio")!, UIImage.init(named: "Shopio")!, UIImage.init(named: "Shopio")!*/]
    private var imageCounter : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true

        // Do any additional setup after loading the view.
        summaryField.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        summaryField.layer.borderWidth = 1.0
        summaryField.layer.cornerRadius = 5
        imageCollection.delegate = self
        imageCollection.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddProductExtraViewController
        destination.setProduct(product: myProduct)
    }
}

//MARK:- IBOutlet Functions
extension AddProductViewController {
    @IBAction func saveProduct(_ sender: Any) {
        if(titleField.text!.isEmpty || priceField.text!.isEmpty || quantityField.text!.isEmpty || myProductPhotos.isEmpty){
            let alert = customNetworkAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let currProduct = PFObject(className: "Product")
            currProduct["userId"] = currentUser?.objectId
            currProduct["title"] = titleField.text!
            currProduct["price"] = Double(priceField.text!)
            currProduct["quantity"] = Int(quantityField.text!)
            currProduct["summary"] = summaryField.text!
            currProduct["shopId"] = myShop?.getShopId()
            
            myProduct = Product(product: currProduct)
            
            currProduct.saveInBackground{(success, error) in
                if(success) {
                    self.myProduct?.setObjectId(product: currProduct)
                    for image in self.myProductPhotos {
                        let productPhoto = PFObject(className: "Product_Images")
                        let imageData = image.jpegData(compressionQuality: 0.5)
                        let imageName = makeImageName(self.titleField.text!)
                        let imageFile = PFFileObject(name: imageName, data:imageData!)
                        
                        productPhoto["productId"] = self.myProduct!.getObjectId()
                        productPhoto["productImage"] = imageFile
                        //Make first picture default
                        if(image == self.myProductPhotos[0]) {
                            productPhoto["isDefault"] = true
                        }
                        productPhoto.saveInBackground()
                    }
                    self.performSegue(withIdentifier: "goToAddProductsExtra", sender: self)
                }
                else{
                    let alert = customNetworkAlert(title: "Could not save Product", errorString: "Please try again later.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        //segue to main
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK:- Display Functions
extension AddProductViewController{
    func setShop(shop: Shop?) {
        self.myShop = shop
    }
    
    func setProduct(product: Product?) {
        self.myProduct = product
    }
}

//MARK:- CollectionView Delegate
extension AddProductViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Image Selection", message: "Select one of the options below", preferredStyle: .actionSheet)
       
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {(action: UIAlertAction) in
            let imagePickerController = ImagePickerController()
            imagePickerController.delegate = self
            self.imageCounter = indexPath.row
            imagePickerController.imageLimit = 4
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        //Render delete button only if current selected item is presenet in the images array
        if(indexPath.row < self.myProductPhotos.count) {
            alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: {(action: UIAlertAction) in
                self.myProductPhotos.remove(at: indexPath.row)
                self.imageCollection.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
}

//MARK:- CollectionView Datasource
extension AddProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = ImageCollectionViewCell()
        if let tempCell = imageCollection.dequeueReusableCell(withReuseIdentifier: "reusableProductImage", for: indexPath) as? ImageCollectionViewCell {
            if(indexPath.row < myProductPhotos.count) {
                tempCell.setImage(image: myProductPhotos[indexPath.row])
            }
            else {
                tempCell.setImage(image: UIImage.init(named: "Shopio")!)
            }
            cell = tempCell
            highlightCell(cell)
        }
        return cell
    }
}

//MARK:- ImagePicker Delegate
extension AddProductViewController: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images {
            if(myProductPhotos.count != 4) {
                myProductPhotos.insert(image, at: imageCounter)
            }
            else{
                myProductPhotos[imageCounter] = image
            }
            imageCounter += 1
        }
        self.imageCollection.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}



