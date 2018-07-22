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
    static let baseURL = URL(string: "https://maps.googleapis.com/maps/api/place/details/json")
    static let detailFields = "formatted_address,opening_hours,photo,name,website,rating,price_level,review,formatted_phone_number"
    static var campgrounds: Result?
    
    static func fetchCampgroundDetailsWith(placeId: String, completion: @escaping ((Result)?) -> Void) {
        
        guard let url = baseURL else { completion(nil) ; return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let placeIdQuery = URLQueryItem(name: "placeid", value: placeId)
        let fieldsQuery = URLQueryItem(name: "fields", value: detailFields)
        let apiKeyQuery = URLQueryItem(name: "key", value: Constants.apiKey)
        
        let queryArray = [placeIdQuery, fieldsQuery, apiKeyQuery]
        components?.queryItems = queryArray
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        print(completeURL)
        
        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
            if let error = error {
                print("DataTask had an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil) ; return
            }
            
            guard let data = data else { completion(nil) ; return }
                
            let jsonDecoder = JSONDecoder()
            do {
                let campgrounds = try jsonDecoder.decode(CampgroundDetailData.self, from: data).result
                self.campgrounds = campgrounds
                completion(campgrounds)
            } catch let error {
                print("Error decoding campground data. Exiting with error: \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
}
