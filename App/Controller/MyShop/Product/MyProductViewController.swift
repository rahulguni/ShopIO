//
//  MyProductViewController.swift
//  App
//
//  Created by Rahul Guni on 7/21/21.
//

import UIKit
import Parse
import RealmSwift
import ImagePicker

class MyProductViewController: UIViewController {
    @IBOutlet weak var productTitle: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productContent: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var discountField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var discountPerLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var messageShopButton: UIButton!
    
    //Get the product from shop view
    private var myProduct: Product?
    private var productImages: [ProductImage] = []
    private var myShop: Shop?
    var productMode: ProductMode?
    
    let realm = try! Realm()
    
    //keep track of imageview
    var currentImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Fix Buttons
        let currentButtons: [UIButton] = [updateButton, addToCartButton, requestButton, messageShopButton]
        modifyButtons(buttons: currentButtons)
        
        self.productTitle.text = myProduct!.getTitle()
        self.priceField.text = myProduct!.getPriceAsString()
        self.quantityField.text = String(myProduct!.getQuantity())
        self.productDescription.text = myProduct!.getSummary()
        self.quantityStepper.value = Double(myProduct!.getQuantity())
        
        if(myProduct?.getDiscount() != 0) {
            discountField.isHidden = false
            let attributeString = makeStrikethroughText(product: myProduct!)
            self.discountField.attributedText = attributeString
        }
        
        getImages()
        setProductsPage(productMode!)
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyProductWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier! == "goToMyStore") {
            let destination = segue.destination as! MyStoreViewController
            destination.replaceProduct(with: myProduct!)
        }
        if(segue.identifier! == "goToUpdateProducts") {
            let destination = segue.destination as! UpdateProductCollectionViewController
            destination.replaceProduct(with: myProduct!)
        }
        if(segue.identifier! == "goToSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forMyProduct
        }
        if(segue.identifier! == "goToProductPhoto") {
            let destination = segue.destination as! ProductImageViewController
            destination.setImage(displayImage: productImages[currentImageIndex].getUIImage()!)
            destination.setProductMode(productMode: self.productMode!)
            destination.setCurrentPictureId(objectId: productImages[currentImageIndex].getObjectId())
            for product in productImages {
                if product.getDefaultStatus() == true {
                    destination.setDisplayPic(objectId: product.getObjectId())
                }
            }
        }
    }
    
}

//MARK:- IBOutlet Functions
extension MyProductViewController {
    @IBAction func updateProduct(_ sender: Any) {
        if(productTitle.text!.isEmpty || priceField.text!.isEmpty || discountField.text!.isEmpty || quantityField.text!.isEmpty){
            let alert = customNetworkAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let query = PFQuery(className: "Product")
            query.getObjectInBackground(withId: myProduct!.getObjectId()) {(product: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                }
                else if let product = product {
                    product["title"] = self.productTitle.text!
                    product["summary"] = self.productDescription.text!
                    product["price"] = makeDouble(self.priceField.text!)
                    product["discount"] = (makeDouble(self.discountField.text!))
                    product["quantity"] = Int(self.quantityField.text!)
                    product.saveInBackground{(success, error) in
                        if(success) {
                            let tempProd = Product(product: product)
                            self.myProduct = tempProd
                            if(self.productMode == ProductMode.forUpdate) {
                                self.performSegue(withIdentifier: "goToUpdateProducts", sender: self)
                            }
                            if(self.productMode == ProductMode.forOwner) {
                                self.performSegue(withIdentifier: "goToMyStore", sender: self)
                            }
                            if(self.productMode == ProductMode.forRequest) {
                                self.performSegue(withIdentifier: "goToMyRequests", sender: self)
                            }
                        }
                        else {
                            let alert = customNetworkAlert(title: "Could not save object", errorString: "Connection error. Please try again later.")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addToCart(_ sender: Any) {
        if(currentUser != nil) {
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            
            //if object is already in cart, only update quantity
            let cartObject = isInCart()
            if(cartObject != nil){
                try! realm.write {
                    cartObject!.quantity = Int(quantityStepper.value)
                }
            }
            //else add the object to local storage
            else {
                let cartItem = CartItem()
                cartItem.userId = currentUser?.objectId
                cartItem.productId = myProduct?.getObjectId()
                cartItem.price = myProduct?.getPrice()
                cartItem.discount = myProduct?.getDiscountAmount()
                cartItem.productTitle = myProduct?.getTitle()
                cartItem.quantity = Int(quantityStepper.value)
                try! realm.write{
                    realm.add(cartItem)
                }
            }
            
            if(productMode == ProductMode.forCart) {
                performSegue(withIdentifier: "goToMyCart", sender: self)
            }
            
            if(productMode == ProductMode.forPublic) {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    @IBAction func requestClicked(_ sender: Any) {
        if(currentUser != nil) {
            let alert = UIAlertController(title: "Send a request to \(myShop!.getShopTitle()) for \(myProduct!.getTitle())?", message: "Please select below", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Request", comment: "Request Button"), style: .default, handler: { _ in
                let newRequest = PFObject(className: "Request")
                newRequest["shopId"] = self.myShop!.getShopId()
                newRequest["userId"] = currentUser!.objectId
                newRequest["productId"] = self.myProduct!.getObjectId()
                newRequest["fulfilled"] = false
                newRequest.saveInBackground{(success, error) in
                    if(success) {
                        let alert = customNetworkAlert(title: "Request Sent!", errorString: "Wait for the shop to proceed with your request.")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        let alert = customNetworkAlert(title: "Could not send request.", errorString: "Try again")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
            self.requestButton.isEnabled = false
            self.requestButton.alpha = 0.5
        }
        else {
            self.performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
    
    @IBAction func amountStepperChange(_ sender: UIStepper) {
        self.quantityField.text = (Int)(sender.value).description
    }
    
    @IBAction func goToProductPhoto(_ sender: Any) {
        if(productMode == ProductMode.forOwner || productMode == ProductMode.forUpdate) {
            imageOptions()
        }
        else {
            self.performSegue(withIdentifier: "goToProductPhoto", sender: self)
        }
    }
    
    @IBAction func messageShopClicked(_ sender: Any) {
        if(currentUser != nil) {
            let alert = UIAlertController(title: "Send a message to \(myShop!.getShopTitle()).", message: "", preferredStyle: .alert)
            alert.addTextField{(textField : UITextField!) -> Void in
                textField.placeholder = "Enter Message"
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: "Send Button"), style: .default, handler: { _ in
                let firstTextField = alert.textFields![0] as UITextField
                if(firstTextField.text != "") {
                    self.sendMessage(currMessage: firstTextField.text!)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "goToSignIn", sender: self)
        }
    }
}

//MARK:- Display Functions
extension MyProductViewController {
    
    func setMyProduct(product myProduct: Product) {
        self.myProduct = myProduct
    }
    
    func setMyShop(shop myShop: Shop) {
        self.myShop = myShop
    }
    
    func setImages(myImages currImages: [ProductImage]) {
        self.productImages = currImages
    }
    
    //check if item is in cart and return cartobject
    private func isInCart() -> CartItem? {
        var myItem: CartItem?
        //search if this product already exists in cart
        let myCartItems = realm.objects(CartItem.self)
        for item in myCartItems {
            //return true if item already in cart
            if(item["productId"] as! String == myProduct!.getObjectId()) {
                if((item["userId"] as! String) == currentUser?.objectId) {
                    myItem = item
                }
            }
        }
        return myItem
    }
    
    //function to send message
    func sendMessage(currMessage: String){
        //search if chatroom already exists
        let query = PFQuery(className: "Messages")
        query.whereKey("senderId", equalTo: currentUser!.objectId!)
        query.whereKey("receiverId", equalTo: self.myShop!.getShopId())
        query.getFirstObjectInBackground{(message, error) in
            if let message = message {
                //chatRoom already exists, add to chat.
                let chatRoom = PFObject(className: "ChatRoom")
                chatRoom["chatRoomId"] = message.objectId!
                chatRoom["senderId"] = currentUser?.objectId!
                chatRoom["message"] = currMessage
                
                message["updatedAt"] = Date()
                message.saveEventually()
                chatRoom.saveEventually()
            }
            //if not exists, create one and send message.
            else {
                let message = PFObject(className: "Messages")
                message["senderId"] = currentUser!.objectId!
                message["receiverId"] = self.myShop!.getShopId()
                
                message.saveInBackground{(success, error) in
                    if(success) {
                        let chatRoom = PFObject(className: "ChatRoom")
                        chatRoom["chatRoomId"] = message.objectId!
                        chatRoom["senderId"] = currentUser?.objectId!
                        chatRoom["message"] = currMessage
                        
                        chatRoom.saveEventually()
                    }
                    else {
                        let alert = customNetworkAlert(title: "Error", errorString: "Could not message at this time.")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func setProductsPage(_ editMode: ProductMode) {
        if(editMode == ProductMode.forOwner || editMode == ProductMode.forUpdate || editMode == ProductMode.forRequest) {
            setOwnerDisplay()
        }
        else if(editMode == ProductMode.forMyShop) {
            self.addToCartButton.isHidden = true
        }
        else if (editMode == ProductMode.forPublic){
            let cartObject = isInCart()
            if(cartObject != nil) {
                setCartDisplay(cartObject!)
            }
            else {
                setPublicDisplay()
            }
        }
        else if (editMode == ProductMode.forCart) {
            let cartObject = isInCart()
            setCartDisplay(cartObject!)
        }
    }
    
    private func imageOptions() {
        let alert = UIAlertController(title: "Edit Image", message: "Choose what you want to do with this image.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit Photo", style: .default, handler: {(action: UIAlertAction) in
            self.performSegue(withIdentifier: "goToProductPhoto", sender: self)
        }))
        if(self.productImages.count < 4) {
            alert.addAction(UIAlertAction(title: "Add Photo", style: .default, handler: {(action: UIAlertAction) in
                self.addPhoto()
            }))
        }
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .default, handler: {(action: UIAlertAction) in
            self.deletePhoto()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addPhoto() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4 - productImages.count
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func deletePhoto(){
        let alert = UIAlertController(title: "Are you sure you want to delete this image?", message: "Please select below", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No Delete Image"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Delete Image"), style: .default, handler: { _ in
            if(self.productImages[self.currentImageIndex].getDefaultStatus() == false) {
                let query = PFQuery(className: "Product_Images")
                query.whereKey("objectId", contains: self.productImages[self.currentImageIndex].getObjectId())
                query.getFirstObjectInBackground{(object, error) in
                    if(object != nil) {
                        object?.deleteInBackground{(success, error) in
                            if(success) {
                                self.productImages.remove(at: self.currentImageIndex)
                                let alert = customNetworkAlert(title: "Successfully Deleted Photo", errorString: "Your Photo has been deleted from \(self.myShop!.getShopTitle())")
                                self.getImages()
                                self.present(alert, animated: true, completion: nil)
                            }
                            else {
                                let alert = customNetworkAlert(title: "Cannot delete image", errorString: "This image cannot be deleted at this moment. Please try later")
                                self.present(alert, animated: true, completion: nil)
                            }

                        }
                    }
                    else {
                        print(error.debugDescription)
                    }
                }
            }
            else {
                let alert = customNetworkAlert(title: "Cannot Delete", errorString: "This is your display picture. Change your display picture if you want to delete this photo.")
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getImages() {
        for image in productImages {
            image.getImage().getDataInBackground{ (imageData: Data?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let imageData = imageData {
                    let myimage = UIImage(data:imageData)
                    image.setImage(image: myimage!)
                }
                self.imageView.reloadInputViews()
                self.configurePageViewController()
            }
        }
    }
    
    private func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePageViewController") as? ImagePageViewController else {
            print("pageViewController")
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(pageViewController.view)
        
        let views: [String: Any] = ["pageView" : pageViewController.view!]

        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))

        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentImageIndex) else {
            //2. error
            print("startingViewController")
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func detailViewControllerAt(index: Int) -> ProductImageViewController? {
        
        print(index)
        
        if(index >= productImages.count || productImages.count == 0) {
            //1. error
            print("Index error")
            return nil
        }
        
        guard let productImageViewController = storyboard?.instantiateViewController(withIdentifier: "ProductImageViewController") as? ProductImageViewController else {
            print("productImageViewController")
            return nil
        }
        
        productImageViewController.setIndex(index: index)
        productImageViewController.setImage(displayImage: productImages[index].getUIImage())

        return productImageViewController
    }
    
    private func setOwnerDisplay() {
        self.productTitle.isUserInteractionEnabled = true
        self.productDescription.isUserInteractionEnabled = true
        self.productContent.isUserInteractionEnabled = true
        self.discountField.isUserInteractionEnabled = true
        self.priceField.isUserInteractionEnabled = true
        self.priceField.text = self.myProduct!.getOriginalPrice()
        self.quantityField.isUserInteractionEnabled = true
        self.discountField.borderStyle = UITextField.BorderStyle.roundedRect
        self.priceField.borderStyle = UITextField.BorderStyle.roundedRect
        self.quantityField.borderStyle = UITextField.BorderStyle.roundedRect
        self.quantityStepper.isHidden = false
        self.discountField.text = nil
        self.discountField.isHidden = false
        self.discountField.placeholder = "Discount"
        self.updateButton.isHidden = false
        self.discountPerLabel.isHidden = false
    }
    
    private func setCartDisplay(_ cartObject: CartItem) {
        self.addToCartButton.isHidden = false
        self.addToCartButton.setTitle("Update Cart", for: .normal)
        self.quantityStepper.isHidden = false
        self.quantityField.text = String(cartObject.quantity!)
        self.quantityStepper.value = Double(cartObject.quantity!)
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
    }
    
    private func setPublicDisplay(){
        self.quantityStepper.isHidden = false
        self.quantityStepper.value = 1.0
        self.quantityField.text = "1"
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
        self.addToCartButton.isHidden = false
        self.messageShopButton.isHidden = false
        if(myProduct!.getQuantity() == 0) {
            self.quantityField.text = "0"
            self.addToCartButton.isHidden = true
            self.updateButton.isHidden = true
            self.requestButton.isHidden = false
        }
    }
}

//MARK: - UIPageViewControllerDelegate
extension MyProductViewController: UIPageViewControllerDelegate {
    /*func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        print(currentImageIndex)
        return currentImageIndex
    }*/
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.productImages.count
    }
}


//MARK: - UIPageViewControllerDataSource
extension MyProductViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let productImageViewController = viewController as? ProductImageViewController
        
        guard var currentIndex = productImageViewController?.getIndex() else {
            return nil
        }
        
        currentImageIndex = currentIndex
        
        if(currentIndex == 0) {
            return nil
        }
        
        currentIndex -= 1
        return detailViewControllerAt(index: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let productImageViewController = viewController as? ProductImageViewController
        
        guard var currentIndex = productImageViewController?.getIndex() else {
            return nil
        }
        
        if(currentIndex == productImages.count) {
            return nil
        }
        
        
        currentImageIndex = currentIndex
        currentIndex += 1
        
        return detailViewControllerAt(index: currentIndex)
    }
}

//MARK:- ImagePicker Delegate

extension MyProductViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images {
            //upload image to the database
            let newImage = PFObject(className: "Product_Images")
            let imageData = image.pngData()
            let imageName = makeImageName(self.myProduct!.getTitle())
            let imageFile = PFFileObject(name: imageName, data: imageData!)
            
            newImage["productId"] = self.myProduct?.getObjectId()
            newImage["productImage"] = imageFile
            
            newImage.saveInBackground{(success, error) in
                if(success) {
                    let newImage = ProductImage(image: newImage)
                    self.productImages.append(newImage)
                }
                else {
                    print(error.debugDescription)
                }
                self.getImages()
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
