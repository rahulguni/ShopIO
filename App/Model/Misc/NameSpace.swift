//
//  NameSpace.swift
//  App
//
//  Created by Rahul Guni on 9/23/21.
//

import Foundation

struct ShopIO {
    //Default variables
    class ParseServer {
        let objectId: String = "objectId"
        let createdAt: String = "createdAt"
        let updatedAt: String = "updatedAt"
    }
    
    //User Table Namespace
    class User: ParseServer {
        let tableName: String = "_User"
        let username: String = "username"
        let password: String = "password"
        let email: String = "email"
        let intro: String = "intro"
        let phone: String = "phone"
        let fName: String = "fName"
        let lastLogin: String = "lastLogin"
        let lName: String = "lName"
        let displayImage: String = "displayImage"
    }
    
    //Address Table Namespace
    class Address: ParseServer {
        let addressTableName: String = "Address"
        let userId: String = "userId"
        let line1: String = "line_1"
        let line2: String = "line_2"
        let city: String = "city"
        let state: String = "state"
        let country: String = "country"
        let phone: String = "phone"
        let isDefault: String = "isDefault"
        let zip: String = "zip"
        let geoPoints: String = "geoPoints"
    }
    
    //ChatRoom Table Namespace
    class ChatRoom: ParseServer {
        let tableName: String = "ChatRoom"
        let message: String = "message"
        let senderId: String = "senderId"
        let chatRoomId: String = "chatRoomId"
    }
    
    //Followings Table Namespace
    class Followings: ParseServer {
        let tableName: String = "Followings"
        let userId: String = "userId"
        let shopId: String = "shopId"
    }
    
    //Messages Table Namespace
    class Messages: ParseServer {
        let tableName: String = "Messages"
        let receiverId: String = "receiverId"
        let senderId: String = "senderId"
    }
    
    //Order Table Namespace
    class Order: ParseServer {
        let tableName: String = "Order"
        let userId: String = "userId"
        let sessionId: String = "sessionId"
        let subTotal: String = "subTotal"
        let itemDiscount: String = "itemDiscount"
        let tax: String = "tax"
        let shipping: String = "shipping"
        let total: String = "total"
        let addressId: String = "addressId"
        let shopId: String = "shopId"
        let pickUp: String = "pickUp"
        let fulfilled: String = "fulfilled"
    }
    
    //Order_Item Table Namespace
    class Order_Item: ParseServer {
        let tableName: String = "Order_Item"
        let productId: String = "productId"
        let orderId: String = "orderId"
        let price: String = "price"
        let discount: String = "discount"
        let quantity: String = "quantity"
    }
    
    //Product Table Namespace
    class Product: ParseServer {
        let tableName: String = "Product"
        let userId: String = "userId"
        let title: String = "title"
        let summary: String = "summary"
        let price: String = "price"
        let discount: String = "discount"
        let quantity: String = "quantity"
        let content: String = "content"
        let shopId: String = "shopId"
    }
    
    //Product_Images Table Namespace
    class Product_Images: ParseServer {
        let tableName: String = "Product_Images"
        let isDefault: String = "isDefault"
        let productId: String = "productId"
        let productImage: String = "productImage"
    }
    
    //Product_Review Table Namespace
    class Product_Review: ParseServer {
        let tableName: String = "Product_Review"
        let productId: String = "productId"
        let title: String = "title"
        let rating: String = "rating"
        let content: String = "content"
        let userId: String = "userId"
    }
    
    //Request Table Namespace
    class Request: ParseServer {
        let tableName: String = "Request"
        let shopId: String = "shopId"
        let userId: String = "userId"
        let productId: String = "productId"
        let fulfilled: String = "fulfilled"
    }
    
    //Shop Table Namespace
    class Shop: ParseServer {
        let tableName: String = "Shop"
        let title: String = "title"
        let userId: String = "userId"
        let slogan: String = "slogan"
        let shopImage: String = "shopImage"
        let shippingCost: String = "shippingCost"
        let geoPoints: String = "geoPoints"
    }
    
    //Shop_Address Table Namespace
    class Shop_Address: ShopIO.Address {
        let shopAddressTableName: String = "Shop_Address"
        let shopId: String = "shopId"
    }
}
