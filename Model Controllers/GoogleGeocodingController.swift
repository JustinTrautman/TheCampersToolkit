//
//  GoogleGeocodingController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 8/26/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

class GoogleGeocodingController {
    
    static let baseURL = URL(string: "https://maps.googleapis.com/maps/api/geocode/json")
    static var geocodingData: [Results]?
    
    static func getCoordinatesFrom(adress: String, completion: @escaping([Results]?) -> Void) {
        
        guard var url = baseURL else { completion(nil) ; return }
        let addressQuery = URLQueryItem(name: "address", value: adress)
        let apiKeyQuery = URLQueryItem(name: "key", value: Constants.googleApiKey)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let queryArray = [addressQuery, apiKeyQuery]
        components?.queryItems = queryArray
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
            if let error = error {
                print("DataTask had and issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil) ; return
            }
            
            guard let data = data else { completion(nil) ; return }
            let jsonDecoder = JSONDecoder()
            
            do {
                let geocoding = try jsonDecoder.decode(GeocodingData.self, from: data).results
                self.geocodingData = geocoding
                completion(geocodingData)
            } catch let error {
                print("Error decoding geocoding data. Exiting with error: \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
}

