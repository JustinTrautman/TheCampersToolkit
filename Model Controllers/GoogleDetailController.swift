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
    static var campgrounds: [TopLevelData] = []
    
    static func fetchCampgroundDetailsFrom(placeID: String, completion: @escaping ([TopLevelData]?) -> Void ) {
        
        let baseURL = URL(string: "https://maps.googleapis.com/maps/api/place/details/json")
        
        guard let url = baseURL else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let placeIDQuery = URLQueryItem(name: "placeid", value: placeID)
        let fieldsQuery = URLQueryItem(name: "fields", value: "name,price_level,rating,review,formatted_phone_number")
        let apiKeyQuery = URLQueryItem(name: "key", value: "AIzaSyDUtXqYOXGy6xyKGwCHi9YGUpxM2fY9V-c")
        
        let queryArray = [placeIDQuery, fieldsQuery, apiKeyQuery]
        
        components?.queryItems = queryArray
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        print(completeURL)
        
        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
            if let error = error {
                print("DataTask had an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            let jsonDecoder = JSONDecoder()
            
            do {
                let campground = try jsonDecoder.decode([TopLevelData].self, from: data)
                self.campgrounds = campground
                completion(campground)
            } catch let error {
                print("Error decoding campground data: \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
}
