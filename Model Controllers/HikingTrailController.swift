/*
 ----------------------------------------------------------------------------------------
 
 HikingTrailController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/23/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */


import UIKit

class HikingTrailController {
    
    static let baseURL = URL(string: "https://www.hikingproject.com/data/get-trails")
    static var trails: [Trails] = []
    static let apiKey = "200313384-ed89aa5429bc44e7980af8b4d6c58a3a"
    
    static func fetchHikingTrailsNear(latitude: String, longitude: String, completion: @escaping ([Trails]?) -> Void) {
        
        guard let url = baseURL else { completion(nil) ; return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let latitudeQuery = URLQueryItem(name: "lat", value: latitude)
        let longitudeQeury = URLQueryItem(name: "lon", value: longitude)
        let apiKeyQuery = URLQueryItem(name: "key", value: apiKey)
        
        let queryArray = [latitudeQuery, longitudeQeury, apiKeyQuery]
        components?.queryItems = queryArray
        
        guard let completeURL = components?.url else { completion(nil) ; return }
        
        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
            if let error = error {
                print("DataTask had an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            let jsonDecoder = JSONDecoder()
            do {
                 let trails = try jsonDecoder.decode(HikingTrailData.self, from: data).trails
                self.trails = trails
                completion(trails)

            } catch let error {
                print("Error decoding campground data. Exiting with error: \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
    
    static func fetchTrailImageWith(photoURL: String, completion: @escaping ((UIImage?)) -> Void) {
        
        guard let url = URL(string: photoURL) else { completion(nil) ; return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("DataTask had an issue getting an image from the network. Exiting with error: \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
