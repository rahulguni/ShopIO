//
//  General.swift
//  App
//
//  Created by Rahul Guni on 7/15/21.
//  General Functions
//

import Foundation
import UIKit

func modifyButtons(buttons: Array<UIButton>) {
    for button in buttons {
        button.layer.cornerRadius = 45
        button.layer.masksToBounds = true
    }
}

func modifyButton(button: UIButton) {
    button.layer.cornerRadius = 45
    button.layer.masksToBounds = true
}
