import Foundation

/**/
/*
class Cart

DESCRIPTION
        This class is the model to make an object that corresponds to the Orders Table. This class also has all the
        required setter and getter properies for the parameters.
 
AUTHOR
        Rahul Guni
 
DATE
        07/24//2021
 
*/
/**/

class Cart {
    private final var userId = currentUser!.objectId!           //userId assosciated with the order
    private var sessionId: String = currentUser!.sessionToken!  //session token of the user while ordering
    private var subTotal: Double?
    private var itemDiscount: Double?
    private var tax: Double?
    private var shipping: Double?
    private var total: Double?
    private var addressId: String?                              //shipment address of the order, foreign key to address table.
    
    //constructor
    init(cartItems: [CartItem]){
        var currTotal = 0.0
        var currDiscount = 0.0
        for item in cartItems {
            currTotal += (item.price!) * Double(item.quantity!)
            currDiscount += (item.discount!) * Double(item.quantity!)
        }
        self.total = currTotal
        self.itemDiscount = currDiscount
        self.tax = (0.05 * self.total!)
    }
    
    func getTotalAsString() -> String {
        return "Total: $" + String(format: "%.2f" ,self.total!) + " + tax"
    }
    
    func getTotal() -> Double {
        return (self.total! * 100).rounded() / 100
     }
    
    func setAddresId(addressId: String) {
        self.addressId = addressId
    }
    
    func getSubTotal() -> Double {
        if(self.shipping != nil) {
            self.subTotal = self.total! + self.tax! + self.shipping!
        }
        else{
            self.subTotal = self.total! + self.tax!
        }
        return (self.subTotal! * 100).rounded() / 100
    }
    
    func getSubTotalAsString() -> String {
        if(self.shipping != nil) {
            self.subTotal = self.total! + self.tax! + self.shipping!
        }
        else{
            self.subTotal = self.total! + self.tax!
        }
        return "SubTotal: $" + String(format: "%.2f" ,self.subTotal!)
    }
    
    func getTax() -> Double {
        return (self.tax! * 100).rounded() / 100
    }
    
    func getTaxAsString() -> String {
        return "Tax: $" + String(format: "%.2f" ,self.tax!)
    }
    
    func getAddressId() -> String {
        return self.addressId!
    }
    
    func getItemDiscount() -> Double {
        return (self.itemDiscount! * 100).rounded() / 100
    }
    
    func getSessionId() -> String {
        return self.sessionId
    }
    
    func getShippingPrice() -> Double {
        return (self.shipping! * 100).rounded() / 100
    }
    
    func getShippingAsString() -> String {
        return "Tax: $" + String(format: "%.2f" ,self.shipping!)
    }
 
    func setShippingPrice(shipping: Double) {
        self.shipping = shipping
    }
}
