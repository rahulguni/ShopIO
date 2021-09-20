//
//  General.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//  General Functions
//

import Foundation
import UIKit

//function to make keyboard disappear when tapped around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//function to make an array of buttons of a single view uniform
func modifyButtons(buttons: Array<UIButton>) {
    for button in buttons {
        button.layer.cornerRadius = 45
        button.layer.masksToBounds = true
    }
}

//function to make a single button uniform
func modifyButton(button: UIButton) {
    button.layer.cornerRadius = 45
    button.layer.masksToBounds = true
}

//function to highlight uicollectionviewcell
func highlightCell(_ cell: UICollectionViewCell) {
    cell.contentView.layer.cornerRadius = 2.0
    cell.contentView.layer.borderWidth = 1.0
    cell.contentView.layer.borderColor = UIColor.black.cgColor
    //cell.contentView.layer.masksToBounds = true

//    cell.layer.shadowColor = UIColor.black.cgColor
//    cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//    cell.layer.shadowRadius = 2.0
//    cell.layer.shadowOpacity = 0.5
//    cell.layer.masksToBounds = false
//    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
}

//function to make strikethrough text for product discount
func makeStrikethroughText(product currProduct: Product) -> NSMutableAttributedString {
    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: currProduct.getOriginalPrice())
    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
    attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
    attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
    
    return attributeString
}

//make double from textfield
func makeDouble(_ textField: String) -> Double? {
    var temp = textField
    if(textField.first == "$") {
        temp = String(textField.dropFirst())
    }
    return Double(temp)
}

//filename for database
func makeImageName(_ name: String) -> String {
    let date = Date().description.split(separator: " ")[0].replacingOccurrences(of: "-", with: "")
    
    return (date + name + ".jpeg")
}

func isValidPhone(phone: String) -> Bool{
    if(phone.count == 10) {
        return true
    }
    return false
}

//func checkPrice(price: String) -> Bool {
//    
//}

//make picture rounded
func makePictureRounded(picture: UIImageView) {
    picture.layer.borderWidth = 1
    picture.layer.masksToBounds = true
    picture.layer.borderColor = UIColor.black.cgColor
    picture.layer.cornerRadius = (picture.frame.size.height / 2)
}

//move array element to first for messages
func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
    var arr = array
    let element = arr.remove(at: fromIndex)
    arr.insert(element, at: toIndex)
    return arr
}

func resizeImage(image: UIImage) -> UIImage? {
    let size = image.size
    let targetSize = CGSize(width: 100, height: 100)
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
