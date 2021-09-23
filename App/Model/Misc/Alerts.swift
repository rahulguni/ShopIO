import Foundation
import UIKit

/**/
/*
 func customNetworkAlert(title myTitle: String, errorString error: String)

NAME

        customNetworkAlert - Makes an error alert using the UIAlertController class.

SYNOPSIS

        func customNetworkAlert(title myTitle: String, errorString error: String)
            title             --> Title of the alert
            errorString       --> Error message of the alert

DESCRIPTION

        This function the title and error message of the alert as a string and displays them in the alert.

RETURNS

        UIAlertController

AUTHOR

        Rahul Guni

DATE

        05/18/2021

*/
/**/
func customNetworkAlert(title myTitle: String, errorString error: String) -> UIAlertController {
    let alert = UIAlertController(title: myTitle, message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
    }))
    return alert
}

/*func customNetworkAlert(title myTitle: String, errorString error: String)*/

