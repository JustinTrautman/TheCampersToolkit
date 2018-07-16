//
//  GooglePlace.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/16/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GooglePlace {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    var photoReference: String?
    var photo: UIImage?
    
    init(dictionary: [String: Any], acceptedTypes: [String])
    {
        let json = JSON(dictionary)
        id = json["place_id"].stringValue
        name = json["name"].stringValue
        address = json["vicinity"].stringValue
        
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        photoReference = json["photos"][0]["photo_reference"].string
        
        var foundType = "campground"
        let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["campground"]
        
        if let types = json["types"].arrayObject as? [String] {
            for type in types {
                if possibleTypes.contains(type) {
                    foundType = type
                    break
                }
            }
        }
        placeType = foundType
    }
}
