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
    
    static func showNetworkConnectivityErrorAlert(vc: UIViewController) {
        let alertController = UIAlertController(title: "Network Error", message: "A network error prevented us from completing the request. Please refresh and we'll get it sorted out.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (refresh) in
            // Notify controller that the user would like to retry request.
            NotificationCenter.default.post(name: Constants.networkRefreshKey, object: nil)
        }))
        
        DispatchQueue.main.async {
            vc.present(alertController, animated: true)
        }
    }
    
    static func showNoCampgroundsAlert(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "There were no campgrounds found within 30 miles. Try searching another area.", message: "")
    }
    
    static func showNoReviewsFound(for campground: String, on vc: UIViewController) {
        showCustomAlert(on: vc, title: "\(campground) doesn't have any reviews.", message: "")
    }
    
    static func showNoPhotosFound(for campground: String, on vc: UIViewController) {
        showCustomAlert(on: vc, title: "\(campground) doesn't have any photos", message: "")
    }
    
    static func showAgreementAlert(on vc: UIViewController) {
        let alertController = UIAlertController(title: "Please agree to ToU", message: "By using the boondocking feature of this app, you argee to the boondocking Terms of Use.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Read ToU", style: .default, handler: { (read) in
            OpenUrlHelper.openWebsite(with: "https://modularmobile.net/boondocker-terms-of-use/", on: vc)
        }))
        alertController.addAction(UIAlertAction(title: "I Agree", style: .default, handler: { (agree) in
            UserDefaults.standard.setValue("True", forKey: "Alerted")
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Constants.agreeKey, object: nil)
        }))
        
        DispatchQueue.main.async {
            vc.present(alertController, animated: true)
        }
    }
    
    static func showSupportAlert(on vc: UIViewController) {
        showCustomAlert(on: vc, title: "You may send support questions, feature requests, or report any data inaccuracies to support@modularmobile.net", message: "")
    }
}
