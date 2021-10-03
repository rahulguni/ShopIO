import UIKit
import Parse
import RealmSwift
import ImagePicker

/**/
/*
class InboxViewController

DESCRIPTION
        This class is a UIViewController that controls MyStore.storyboard's MyProduct view.
 
AUTHOR
        Rahul Guni
 
DATE
        07/21/2021
 
*/
/**/

class MyProductViewController: UIViewController {
    
    //IBOutlet Elements
    @IBOutlet weak var productTitle: UITextField!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productContent: UITextView!
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
    @IBOutlet weak var ratingsButton: UIButton!
    
    private var myProduct: Product?                     //Get the product from shop view
    private var productImages: [ProductImage] = []      //current Product images
    private var productReview: [ProductReview] = []     //current Product Reviews
    private var myShop: Shop?                           //current Shop
    var productMode: ProductMode?                       //productMode to render view for public/shop/edit etc.
    let realm = try! Realm()
    var currentImageIndex = 0                           //keep track of imageview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        //Fix Buttons
        modifyButtons(buttons: [updateButton, addToCartButton, requestButton, messageShopButton])
        textViewBordered([productDescription, productContent])
        
        self.productTitle.text = myProduct!.getTitle()
        self.priceField.text = myProduct!.getPriceAsString()
        self.quantityField.text = String(myProduct!.getQuantity())
        self.productDescription.text = myProduct!.getSummary()
        self.productContent.text = myProduct!.getContent()
        self.quantityStepper.value = Double(myProduct!.getQuantity())
        
        self.priceField.delegate = self
        
        //Hide discount field if current product has no discount
        if(myProduct?.getDiscount() != 0) {
            discountField.isHidden = false
            let attributeString = makeStrikethroughText(product: myProduct!)
            self.discountField.attributedText = attributeString
        }
        
        getImages()
        setProductsPage(productMode!)
        checkReviews()
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
        
        if(segue.identifier! == "goToRatings") {
            let destination = segue.destination as! ProductReviewViewController
            destination.setRatings(ratings: self.productReview)
            destination.setProduct(product: self.myProduct!)
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
    
    /**/
    /*
    @IBAction func updateProduct(_ sender: Any)

    NAME

            updateProduct - Action for button Update click.

    DESCRIPTION

            This function first checks all the required product field is filled. Then it presents an alert to confirm the update. If
            confirmed, it updates the product.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    @IBAction func updateProduct(_ sender: Any) {
        
        if(productTitle.text!.isEmpty || priceField.text!.isEmpty || discountField.text!.isEmpty || quantityField.text!.isEmpty){
            let alert = customNetworkAlert(title: "Mising Entry Field", errorString: "Please make sure you have filled all the required fields.")
            self.present(alert, animated: true, completion: nil)
        }
        //Remove 'or true' to restrict from updating the product if it was modified within the last 24 hours.
        else if(NSDate() as Date >= myProduct!.getUpdateDate().addingTimeInterval(86400) || true) {
            let alert = UIAlertController(title: "Update Product?", message: "Please select below", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm Button"), style: .default, handler: { _ in
                self.updateProduct()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = customNetworkAlert(title: "Cannot Update Product.", errorString: "It seems like you have already updated your product once in the last 24 hours.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    /* @IBAction func updateProduct(_ sender: Any) */
    
    /**/
    /*
    @IBAction func addToCart(_ sender: Any)

    NAME

            addToCart - Action for button Add to cart click.

    DESCRIPTION

            This function first checks if the product is already in user's cart. If true, then only the quantity is updated. Otherwise,
            the product is added to user's cart in Realm.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
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
                cartItem.productShop = myProduct?.getShopId()
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
    /* @IBAction func addToCart(_ sender: Any) */
    
    /**/
    /*
    @IBAction func requestClicked(_ sender: Any)

    NAME

            requestClicked - Action for button Request click.

    DESCRIPTION

            Requests button is only available if the quantity of product in store is 0. This function presents an alert and uploads
            a new Request object in Requests table with the current product's objectId and current shop's objectId.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    @IBAction func requestClicked(_ sender: Any) {
        if(currentUser != nil) {
            let alert = UIAlertController(title: "Send a request to \(myShop!.getShopTitle()) for \(myProduct!.getTitle())?", message: "Please select below", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Request", comment: "Request Button"), style: .default, handler: { _ in
                let newRequest = PFObject(className: ShopIO.Request().tableName)
                newRequest[ShopIO.Request().shopId] = self.myShop!.getShopId()
                newRequest[ShopIO.Request().userId] = currentUser!.objectId
                newRequest[ShopIO.Request().productId] = self.myProduct!.getObjectId()
                newRequest[ShopIO.Request().fulfilled] = false
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
    /* @IBAction func requestClicked(_ sender: Any) */
    
    //Function to update quantity when stepper is changed
    @IBAction func amountStepperChange(_ sender: UIStepper) {
        self.quantityField.text = (Int)(sender.value).description
    }
    
    //Action for image click
    @IBAction func goToProductPhoto(_ sender: Any) {
        if(productMode == ProductMode.forOwner || productMode == ProductMode.forUpdate) {
            imageOptions()
        }
        else {
            self.performSegue(withIdentifier: "goToProductPhoto", sender: self)
        }
    }
    
    /**/
    /*
    @IBAction func messageShopClicked(_ sender: Any)

    NAME

            messageShopClicked - Action for button Message Shop click.

    DESCRIPTION

            This function presents an alert with user input to send a message to the shop.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
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
    /*@IBAction func messageShopClicked(_ sender: Any)*/
    
    //Action for ratings button clicked
    @IBAction func ratingsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "goToRatings", sender: self)
    }
}

//MARK:- Display Functions
extension MyProductViewController {
    
    //Setter function to set current product
    func setMyProduct(product myProduct: Product) {
        self.myProduct = myProduct
    }
    
    //Setter function to set current shop
    func setMyShop(shop myShop: Shop) {
        self.myShop = myShop
    }
    
    //Setter function to set current product's images
    func setImages(myImages currImages: [ProductImage]) {
        self.productImages = currImages
        var index: Int = 0
        for image in self.productImages {
            //swap display picture to first position
            if (image.getDefaultStatus()){
                self.productImages.swapAt(0, index)
            }
            index += 1
        }
    }
    
    /**/
    /*
    private func updateProduct()

    NAME

            updateProduct - Updates current product.

    DESCRIPTION

            This function first queries the Product table and updates the fetched object. This function also checks validity of
            discount percentage.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    private func updateProduct() {
        let query = PFQuery(className: ShopIO.Product().tableName)
        query.getObjectInBackground(withId: myProduct!.getObjectId()) {(product: PFObject?, error: Error?) in
            if let _ = error {
                let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                self.present(alert, animated: true, completion: nil)
            }
            else if let product = product {
                //check discount percentage
                if(makeDouble(self.discountField.text!)! > 100) {
                    let alert = customNetworkAlert(title: "Invalid Discount Percentage", errorString: "Discount percentage must be in the range of 0-100.")
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    product[ShopIO.Product().title] = self.productTitle.text!
                    product[ShopIO.Product().summary] = self.productDescription.text!
                    product[ShopIO.Product().price] = makeDouble(self.priceField.text!)
                    product[ShopIO.Product().discount] = (makeDouble(self.discountField.text!))
                    product[ShopIO.Product().quantity] = Int(self.quantityField.text!)
                    product[ShopIO.Product().content] = self.productContent.text!
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
    /* private func updateProduct() */
    
    /**/
    /*
     private func isInCart() -> CartItem?

    NAME

            isInCart - Checks if current product is already in user's cart

    DESCRIPTION

            This function loops through all items in current user's cart and checks if current product is already
            in cart by comparing objectId's of products. If it already exists, this function returns the CartItem object
            in order to update it in Realm.

    RETURNS

            CartItem? -> Returns an optional CartItem object, nil if product is not found in current user's cart.

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    private func isInCart() -> CartItem? {
        var myItem: CartItem?
        //search if this product already exists in cart
        let myCartItems = realm.objects(CartItem.self)
        for item in myCartItems {
            if(item["productId"] as! String == myProduct!.getObjectId()) {
                if((item["userId"] as! String) == currentUser?.objectId) {
                    myItem = item
                }
            }
        }
        return myItem
    }
    /* private func isInCart() -> CartItem? */
    
    /**/
    /*
    private func sendMessage(text: String)

    NAME

            sendMessage - Uploads message to respective chatRoom and updates the Messages Table.
     
    SYNOPSIS
           
            sendMessage(currMessage: String)
                currMessage        --> Message string to be sent.

    DESCRIPTION

            This function takes in the message string and uploads a new message in the ChatRoom table with appropriate data.
            After this is completed, it updates the updatedAt date in Message table for the current chatRoom.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            8/20/2021

    */
    /**/
    
    //function to send message
    private func sendMessage(currMessage: String){
        //search if chatroom already exists
        let query = PFQuery(className: ShopIO.Messages().tableName)
        query.whereKey(ShopIO.Messages().senderId, equalTo: currentUser!.objectId!)
        query.whereKey(ShopIO.Messages().receiverId, equalTo: self.myShop!.getShopId())
        query.getFirstObjectInBackground{(message, error) in
            if let message = message {
                //chatRoom already exists, add to chat.
                let chatRoom = PFObject(className: ShopIO.ChatRoom().tableName)
                chatRoom[ShopIO.ChatRoom().chatRoomId] = message.objectId!
                chatRoom[ShopIO.ChatRoom().senderId] = currentUser?.objectId!
                chatRoom[ShopIO.ChatRoom().message] = currMessage
                
                message[ShopIO.ChatRoom().updatedAt] = Date()
                message.saveEventually()
                chatRoom.saveEventually()
            }
            //if not exists, create one and send message.
            else {
                let message = PFObject(className: ShopIO.Messages().tableName)
                message[ShopIO.Messages().senderId] = currentUser!.objectId!
                message[ShopIO.Messages().receiverId] = self.myShop!.getShopId()
                
                message.saveInBackground{(success, error) in
                    if(success) {
                        let chatRoom = PFObject(className: ShopIO.ChatRoom().tableName)
                        chatRoom[ShopIO.ChatRoom().chatRoomId] = message.objectId!
                        chatRoom[ShopIO.ChatRoom().senderId] = currentUser?.objectId!
                        chatRoom[ShopIO.ChatRoom().message] = currMessage
                        
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
    /* private func sendMessage(currMessage: String) */
    
    /**/
    /*
    private func checkReviews()

    NAME

            checkReviews - Checks current Product's reviews.

    DESCRIPTION

            This function first queries the Product_Reviews table and fetches review objects for current object. Then, it updates
            the review button's title to average rating followed by number of users who rated.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    private func checkReviews() {
        let query = PFQuery(className: ShopIO.Product_Review().tableName)
        query.whereKey(ShopIO.Product_Review().productId, equalTo: self.myProduct!.getObjectId())
        query.order(byDescending: ShopIO.Product_Review().updatedAt)
        query.findObjectsInBackground{(reviews, errors) in
            if let reviews = reviews {
                var totalReview: Double = 0.0
                var reviewCount: Int = 0
                for review in reviews {
                    let currReview = ProductReview(reviewObject: review)
                    totalReview += Double(currReview.getRating())
                    reviewCount += 1
                    self.productReview.append(currReview)
                    let totalRating = ((totalReview / Double(self.productReview.count)) * 100).rounded() / 100
                    self.ratingsButton.setTitle("Rating: \(totalRating) / 5.0 (\(reviewCount))", for: .normal)
                }
            }
        }
    }
    /* private func checkReviews() */
    
    //Function to set current view according to productMode
    private func setProductsPage(_ editMode: ProductMode) {
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
    
    /**/
    /*
    private func imageOptions()

    NAME

            imageOptions - Presents image options

    DESCRIPTION

            This function presents an alert that have three choices for the selected product image:- Edit, Add (if total
            images < 4) or Delete photo.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
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
    /* private func imageOptions() */
    
    //Function to present image picker
    private func addPhoto() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4 - productImages.count
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    /**/
    /*
    private func deletePhoto()

    NAME

            deletePhoto - Delete selected image

    DESCRIPTION

            This function first queries the Product_Images table for selected image using its objectId. If the selected picture
            is the product's default picture, an alert is presented to the user informing the image cannot be deleted. Otherwise,
            the image is removed both from the table and productImages array.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    private func deletePhoto(){
        let alert = UIAlertController(title: "Are you sure you want to delete this image?", message: "Please select below", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No Delete Image"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Delete Image"), style: .default, handler: { _ in
            if(self.productImages[self.currentImageIndex].getDefaultStatus() == false) {
                let query = PFQuery(className: ShopIO.Product_Images().tableName)
                query.whereKey(ShopIO.Product_Images().objectId, contains: self.productImages[self.currentImageIndex].getObjectId())
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
                        let alert = customNetworkAlert(title: "Unable to connect.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                        self.present(alert, animated: true, completion: nil)
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
    /* private func deletePhoto() */
    
    /**/
    /*
    private func getImages()

    NAME

            getImages - Delete selected image

    DESCRIPTION

            This function loops through the productImages array and puts the images in PageView.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
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
    /* private func getImages() */
    
    private func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: "ImagePageViewController") as? ImagePageViewController else {
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
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func detailViewControllerAt(index: Int) -> ProductImageViewController? {
        if(index >= productImages.count || productImages.count == 0) {
            return nil
        }
        guard let productImageViewController = storyboard?.instantiateViewController(withIdentifier: "ProductImageViewController") as? ProductImageViewController else {
            return nil
        }
        productImageViewController.setIndex(index: index)
        productImageViewController.setImage(displayImage: productImages[index].getUIImage())
        return productImageViewController
    }
    
    //Function to set the view as ShopOwner
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
    
    //Function to set the view as Cart (the product is already in cart)
    private func setCartDisplay(_ cartObject: CartItem) {
        self.addToCartButton.isHidden = false
        self.addToCartButton.setTitle("Update Cart", for: .normal)
        self.quantityStepper.isHidden = false
        self.quantityField.text = String(cartObject.quantity!)
        self.quantityStepper.value = Double(cartObject.quantity!)
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
    }
    
    //Function to set the view for public
    private func setPublicDisplay(){
        self.quantityStepper.isHidden = false
        self.quantityStepper.value = 1.0
        self.quantityField.text = "1"
        self.quantityStepper.minimumValue = 1.0
        self.quantityStepper.maximumValue = Double(myProduct!.getQuantity())
        self.addToCartButton.isHidden = false
        self.messageShopButton.isHidden = false
        if(myProduct!.getQuantity() <= 0) {
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
    
    /**/
    /*
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage])

    NAME

            doneButtonDidPress - Done button pressed in image picker

    DESCRIPTION

            This function uploads the selected images to Product_Images table and appends them to productImages array.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            07/21/2021

    */
    /**/
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images {
            //upload image to the database
            let newImage = PFObject(className: ShopIO.Product_Images().tableName)
            let imageData = image.pngData()
            let imageName = makeImageName(self.myProduct!.getObjectId())
            let imageFile = PFFileObject(name: imageName, data: imageData!)
            
            newImage[ShopIO.Product_Images().productId] = self.myProduct?.getObjectId()
            newImage[ShopIO.Product_Images().productImage] = imageFile
            
            newImage.saveInBackground{(success, error) in
                if(success) {
                    let newImage = ProductImage(image: newImage)
                    self.productImages.append(newImage)
                }
                else {
                    let alert = customNetworkAlert(title: "Unable to add photo.", errorString: "There was an error connecting to the server. Please check your internet connection and try again.")
                    self.present(alert, animated: true, completion: nil)
                }
                self.getImages()
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    /* func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) */
    
    //Action for cancel button click
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITextFieldDelegate
extension MyProductViewController: UITextFieldDelegate {
    
    //Function to not allow more than 2 digits after decimal in price field.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = textField.text! as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        
        //Check the specific textField
        if textField == self.priceField {
            let textArray = resultString.components(separatedBy: ".")
            if textArray.count > 2 { //Allow only one "."
                return false
            }
            if textArray.count == 2 {
                let lastString = textArray.last
                if lastString!.count > 2 { //Check number of decimal places
                    return false
                }
            }
        }
        return true
    }
    
}
