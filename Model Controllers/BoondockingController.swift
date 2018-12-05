/*
 ----------------------------------------------------------------------------------------
 
 BoondockingController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/27/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

class BoondockingController {
    
    static let baseURL = URL(string: Constants.boondockingDatabase)!
    static let getterEndpoint = baseURL.appendingPathComponent(".json")
    static var boondocks: [Boondocking]?
    
    static func fetchAllBoondockingLocations(with authToken: String, completion: @escaping ([Boondocking]?) -> Void) {
        
        var components = URLComponents(url: getterEndpoint, resolvingAgainstBaseURL: true)
        let authQuery = URLQueryItem(name: "auth", value: authToken)
        let queryArry = [authQuery]
        
        components?.queryItems = queryArry
        
        guard let completeUrl = components?.url else {
            return
        }
        
        URLSession.shared.dataTask(with: completeUrl) { (data, _, error) in
            if let error = error {
                print("There was an error retrieving data in \(#function). Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            let jsonDecoder = JSONDecoder()
            do {
                let boondocks = try jsonDecoder.decode([Boondocking].self, from: data)
                self.boondocks = boondocks
                completion(boondocks)
            } catch let error {
                print("Error decoding boondocking locations. \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
}
