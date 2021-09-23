//
//  EnumFiles.swift
//  App
//
//  Created by Rahul Guni on 7/30/21.
//

import Foundation

//options for signIn
enum forSignIn {
    case forAccount
    case forMyShop
    case forMyCart
    case forMyProduct
    case forInbox
}

//Options for Product
enum ProductMode {
    case forMyShop
    case forCart
    case forOwner
    case forPublic
    case forUpdate
    case forRequest
}

//options for address
enum forAddress {
    case forShop
    case forEdit
    case forAddNewShop
    case forShopEdit
    case forPrimary
}
