//
//  ForecastedWeatherController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 8/25/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

class ForeCastedWeaterController {
    
    static let baseURL = URL(string: "https://api.weather.gov")
    static var forecastedWeatherData: ForecastedWeatherData?
    
    static func fetchForecastedWeatherFrom(latitude: String, longitude: String, completion: @escaping((ForecastedWeatherData)?) -> Void) {
        
        guard var url = baseURL else { completion(nil) ; return }
        
        url.appendPathComponent("points")
        url.appendPathComponent("\(latitude),\(longitude)")
        url.appendPathComponent("forecast")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        print(completeURL)
        
        URLSession.shared.dataTask(with: completeURL) { (data, road, error) in
            if let error = error {
                print("DataTask has an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil) ; return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let forecastedWeather = try  jsonDecoder.decode(ForecastedWeatherData.self, from: data)
                self.forecastedWeatherData = forecastedWeather
                completion(forecastedWeather)
            } catch let error {
                print("Error decoding forecasted weather data. Exiting with error: \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
}