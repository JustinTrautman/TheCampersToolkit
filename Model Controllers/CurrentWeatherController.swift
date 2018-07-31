//
//  CurrentWeatherController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/22/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

class CurrentWeatherController {
    
    static let shared = CurrentWeatherController()
    static let baseURL = URL(string: "http://api.openweathermap.org/data/2.5/weather")
    
    static var currentWeather: CampgroundWeatherData?
    
    static func fetchCurrentWeatherOf(latitude: String, longitude: String, completion: @escaping ((CampgroundWeatherData)?) -> Void) {
        
        guard let url = baseURL else { completion(nil) ; return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let latitudeQuery = URLQueryItem(name: "lat", value: latitude)
        let longitudeQuery = URLQueryItem(name: "lon", value: longitude)
        let apiKeyQuery = URLQueryItem(name: "appid", value: Constants.openWeatherApiKey)
        let unitsQuery = URLQueryItem(name: "units", value: "imperial")
        
        let queryArray = [latitudeQuery, longitudeQuery, apiKeyQuery, unitsQuery]
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
                let currentWeather = try jsonDecoder.decode(CampgroundWeatherData.self, from: data)
                self.currentWeather = currentWeather
                completion(currentWeather)
            } catch let error {
                print("Error decoding campground data. Exiting with error: \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
}
