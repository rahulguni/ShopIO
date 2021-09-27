import UIKit
import Parse

/**/
/*
class MyShopViewController

DESCRIPTION
        This class is a UIViewController that controls MyShop.storyboard view.
 
AUTHOR
        Rahul Guni
 
DATE
        04/30/2021
 
*/
/**/

class MyShopViewController: UIViewController{
    
    //IBOutlet Elements
    @IBOutlet weak var myShopButton: UIButton!
    @IBOutlet weak var editMyShopButton: UIButton!
    @IBOutlet weak var AddNewShop: UIButton!
    
    var shopManager = ShopManager()         //shopManager Delegate to perform segues accordingly.
    
    override func viewDidLoad() {
        let currentButtons: [UIButton] = [myShopButton, editMyShopButton, AddNewShop]
        modifyButtons(buttons: currentButtons)
        shopManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Make sure to render the right buttons for managing shop
        if currentUser == nil {
            alterButtons(loggedIn: false)
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
        else{
            alterButtons(loggedIn: true)
        }
    }
    
    //Function to unwind the segue and reload view
    @IBAction func unwindToMyShopWithSegue(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.viewDidAppear(true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //function to dismiss the signIn view after login when called from myshop view.
        if(segue.identifier! == "toSignIn") {
            let destination = segue.destination as! SignInViewController
            destination.dismiss = forSignIn.forMyShop
        }
        
        if(segue.identifier! == "goTomyShopView") {
            let destination = segue.destination as! MyStoreViewController
            destination.setShop(shop: shopManager.getCurrShop())
            destination.fillMyProducts(productsList: shopManager.getCurrProducts())
            destination.setForShop(ProductMode.forMyShop)
        }
        
        if(segue.identifier! == "goToManageShop") {
            let destination = segue.destination as! ManageShopViewController
            destination.setShop(shop: shopManager.getCurrShop())
        }
        
    }
    
}

extension MyShopViewController: shopManagerDelegate {
    
    //Function to perform segue
    func goToViewController(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
        
}

//MARK:- IBOutlet Functions
extension MyShopViewController {
    
    //Action for Manage Shop Button Click.
    @IBAction func manageShopButton(_ sender: UIButton) {
        if currentUser != nil{
            self.shopManager.checkShop(identifier: "goToManageShop")
        }
        else{
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    //Action for My Shop Button Click.
    @IBAction func myShopButton(_ sender: UIButton) {
        if currentUser != nil {
            self.shopManager.checkShop(identifier: "goTomyShopView")
        }
        else {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    //Action for Add New Shop Button Click.
    @IBAction func AddNewShop(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
}

//MARK:- Display Functions
extension MyShopViewController {
    //Action to alter buttons according to user sign in status.
    private func alterButtons(loggedIn bool: Bool) {
        AddNewShop.isHidden = bool;
        myShopButton.isHidden = !bool;
        editMyShopButton.isHidden = !bool;
    }
}
