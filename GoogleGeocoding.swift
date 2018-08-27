/*
 ----------------------------------------------------------------------------------------
 
 GoogleGeocoding.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 8/26/18.
 Copyright © 2018 Justin Trautman. All rights reserved.
 Justin@modularmobile.net
 
 Google Geocoding API: https://developers.google.com/maps/documentation/geocoding/start
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct GeocodingData : Codable {
    let results : [Results]?
}

struct Results : Codable {
    let formattedAddress : String?
    let geometry : Geometry?
    let placeID : String?
    
    enum CodingKeys: String, CodingKey {
        
        case formattedAddress = "formatted_address"
        case geometry = "geometry"
        case placeID = "place_id"
    }
}

struct Geometry : Codable {
    let location : Location?
    let locationType : String?
    
    enum CodingKeys: String, CodingKey {
        
        case location
        case locationType = "location_type"
    }
}

struct Location : Codable {
    let lat : Double?
    let lng : Double?
    
    enum CodingKeys: String, CodingKey {
        
        case lat = "lat"
        case lng = "lng"
    }
}
