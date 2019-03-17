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
    static let googleApiKey = "apikey"
    static let openWeatherApiKey = "apikey"
    static let activeApiKey = "apikey"
    static let gasFeedApiKey = "apikey"
    
    
    // Google ad IDs
    static let applicationID = "appId"
    
    // Real Ad Unit ID
//    static let bannerAdUnitID = "unitId"
//    static let interstitialAdUnitID = "unitId"
    
    // Testing ad Unit ID
    static let interstitialAdUnitID = "unitId"
    static let bannerAdUnitID = "unitId"
    
    // Strings
    static let photosBaseURL = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=700?maxHeight=700&photoreference=")
    
    // Notification Keys
    static let updateReviewsKey = Notification.Name("net.modularmobile.updateReviews")
    static let agreeKey = Notification.Name("net.modularmobile.tctTerms")
    static let networkRefreshKey = Notification.Name("net.modularmobile.networkRefresh")
}
