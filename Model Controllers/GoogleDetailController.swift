//
//  GoogleDetailController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/16/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

class GoogleDetailController {
    
    static let shared = GoogleDetailController()
    static var campgrounds: [Result] = []
    
    static func fetchCampgroundDetailsFrom(placeID: String, completion: @escaping () -> Void ) {
        
        let baseURL = URL(string: "https://maps.googleapis.com/maps/api/place/details/json")
        
        guard let url = baseURL else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let placeIDQuery = URLQueryItem(name: "placeid", value: placeID)
        let fieldsQuery = URLQueryItem(name: "fields", value: "name,price_level,rating,review,formatted_phone_number")
        let apiKeyQuery = URLQueryItem(name: "key", value: "AIzaSyDUtXqYOXGy6xyKGwCHi9YGUpxM2fY9V-c")
        
        let queryArray = [placeIDQuery, fieldsQuery, apiKeyQuery]
        
        components?.queryItems = queryArray
    }
}
