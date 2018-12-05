//
//  AlertHelper.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 10/20/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

struct AlertHelper {
    
    static func showCustomAlert(on vc: UIViewController, title: String, message: String) {
        let customAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        customAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            vc.present(customAlert, animated: true)
        }
    }
    
    static func showNoCampgroundsAlert(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "There were no campgrounds found within 31 miles. Try searching another area.", message: "")
    }
    
    static func showAgreementAlert(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "By using the boondocking feature of this app you understand and agree to the ToS in the information section of this screen.", message: "")
    }
    
    static func showBoondockingTerms(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "The boondocking information found within this app is supported by public submission and its accuracy cannot be gauranteed. Please research indivdual sites using the included phone number and website if available. Always check with local authorities to verify the legality of sites before boondocking. I agree that Modular Mobile LLC and its developers are not responsible for any inaccuracies of boondocking infomation", message: "")
    }
    
    static func showSupportAlert(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "You may send support questions, feature requests, or report any data inaccuracies to support@modularmobile.net", message: "")
    }
}
