import Foundation
import RealmSwift

/**/
/*
class CartItem

DESCRIPTION
        Since the cart items are not uploaded remotely, it is instead saved on the device itself using Realm database. This class is an extension of Object used in realm database. link: https://docs.mongodb.com/realm/sdk/ios/
AUTHOR
        Rahul Guni
DATE
        07/24/2021
*/
/**/

class CartItem: Object {
    @Persisted var userId: String?
    @Persisted var productId: String?
    @Persisted var price: Double?
    @Persisted var discount: Double?
    @Persisted var quantity: Int?
    @Persisted var productTitle: String?
    @Persisted var productShop: String?
}

