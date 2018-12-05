/*
 ----------------------------------------------------------------------------------------
 
 Constants.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/21/18.
 Copyright © 2018 Justin Trautman. All rights reserved.
 Justin@modularmobile.net
 
 >>> Comment out real ad unit ID and use testing ad unit ID when testing. <<<
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct Constants {
    
    // API Keys
//     static let googleApiKey = "apikey"
      static let googleApiKey = "BOGUS"
    static let openWeatherApiKey = "apikey"
    static let activeApiKey = "apikey"
    static let gasFeedApiKey = "apikey"
    
    // Databases
    static let boondockingDatabase = "database"
    
    // Google ad IDs
    static let applicationID = "appID"
    
    // Real Ad Unit ID
//    static let bannerAdUnitID = "unitID"
//    static let interstitialAdUnitID = "unitID"
    
    // Testing ad Unit ID
    static let interstitialAdUnitID = "unitID"
    static let bannerAdUnitID = "unitID"
    
    // Notification Keys
    static let updateReviewsKey = Notification.Name("net.modularmobile.updateReviews")
}
