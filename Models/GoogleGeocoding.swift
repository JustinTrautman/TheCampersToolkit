/*
 ----------------------------------------------------------------------------------------
 
 GoogleGeocoding.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 8/26/18.
 Copyright © 2018 Justin Trautman. All rights reserved.
 Justin@modularmobile.net
 
 Combined model for Google Geocoding API and Google Place API.  Geocoding API is used for
 location awareness when searching for places of interest with the Google Place Search API
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct GeocodingData : Codable {
    let results : [Results]?
}

struct Results : Codable {
    let formattedAddress : String?
    let geometry : Geometry?
    // Google Place API
    let name: String?
    let placeID : String?
    
    enum CodingKeys: String, CodingKey {
        
        case formattedAddress = "formatted_address"
        case geometry = "geometry"
        case placeID = "place_id"
        case name
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
