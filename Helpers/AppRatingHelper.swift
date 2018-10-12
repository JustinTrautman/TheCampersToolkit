//
//  AppRatingHelper.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation
import StoreKit

var beenAsked: Bool = false

struct AppRatingHelper {
    static func incrementAppLaunchedCounter() {
        let currentCount = UserDefaults.standard.integer(forKey: "launchCount")
        
        UserDefaults.standard.set(currentCount + 1, forKey: "launchCount")
        UserDefaults.standard.synchronize()
        print("🔥🔥🔥App has been launched \(currentCount + 1) time(s).🔥🔥🔥")
    }
    
    static func askForRating() {
        let appLaunchCount = UserDefaults.standard.integer(forKey: "launchCount")
        
        if beenAsked == false {
        
        switch appLaunchCount {
        case 10, 18, 20, 50, 80:
            AppRatingHelper().requestReview()
            beenAsked = true
        default:
            print("🔥🔥🔥App has been launched \(appLaunchCount) times🔥🔥🔥.")
            break
            }
        }
    }
    
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
