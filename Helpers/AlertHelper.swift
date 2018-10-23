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
}
