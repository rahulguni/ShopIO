//
//  Alerts.swift
//  App
//
//  Created by Rahul Guni on 6/25/21.
//

import Foundation
import UIKit


func customNetworkAlert(title myTitle: String, errorString error: String) -> UIAlertController {
    let alert = UIAlertController(title: myTitle, message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
    }))
    return alert
}

