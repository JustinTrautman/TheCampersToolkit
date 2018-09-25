//
//  GetCoordinates.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 8/26/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class GetCoordinates {
    
    static func getLocationFromAddress(address : String) -> CLLocationCoordinate2D {
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        do {
            let url = String(format: "https://maps.googleapis.com/maps/api/geocode/json?&address=%@&key=\(Constants.googleApiKey)", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
            let result = try Data(contentsOf: URL(string: url)!)
            let json = try JSON(data: result)
            
            lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
            lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
            
        }
        catch let error{
            print(error)
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
