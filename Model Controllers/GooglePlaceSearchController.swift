/*
 ----------------------------------------------------------------------------------------
 
 GooglePlaceSearchController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/17/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Google Place Search API: https://developers.google.com/places/web-service/search
 
 TODO: Version 2.0 - Tell user that the map couldn't populate because they were offline and give them an option to refresh.
  ----------------------------------------------------------------------------------------
 */

import Foundation

class GooglePlaceSearchController {
    
    static let googlePlaceBaseURL = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?")
    static var googlePlaces: [Results]?
    static var selectedType: String?
    
    static func fetchPlacesNearby(latitude: String, longitude: String, radius: Double, keyword: String, completion: @escaping ([Results]?) -> Void) {
        
        guard let url = googlePlaceBaseURL else { completion(nil) ; return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let locationQuery = URLQueryItem(name: "location", value: "\(latitude),\(longitude)")
        let typeQuery = URLQueryItem(name: "type", value: keyword)
        let radiusQuery = URLQueryItem(name: "radius", value: "\(radius)")
        let rankByQuery = URLQueryItem(name: "rankby", value: "prominence")
        let apiQuery = URLQueryItem(name: "key", value: Constants.googleApiKey)
        
        var queryArray = [locationQuery, typeQuery, radiusQuery, rankByQuery, apiQuery]
        
        self.selectedType = keyword
        
        if keyword == "store" {
            let keywordQuery = URLQueryItem(name: "keyword", value: "propane refill")
            queryArray.insert(keywordQuery, at: 2)
        }
        
        components?.queryItems = queryArray
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
            if let error = error {
                print("DataTask had an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil) ; return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            let jsonDecoder = JSONDecoder()
            do {
                let places = try jsonDecoder.decode(GeocodingData.self, from: data).results
                self.googlePlaces = places
                completion(places)
            } catch let error {
                print("Error decoding campground data. Exiting with error: \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
}
