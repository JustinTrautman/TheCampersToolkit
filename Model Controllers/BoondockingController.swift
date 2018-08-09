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
    
    static let shared = BoondockingController()
    static let baseURL = URL(string: "https://the-camper-s-toolkit.firebaseio.com")!
    static let getterEndpoint = baseURL.appendingPathComponent(".json")
    static var boondocks: Boondocking?
    
    static func fetchBoondockingLocationsNear(completion: @escaping ((Boondocking)?) -> Void) {
    
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        print(getterEndpoint)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("There was an error retrieving data in \(#function). Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            let jsonDecoder = JSONDecoder()
            do {
                let boondocks = try jsonDecoder.decode(Boondocking.self, from: data)
                self.boondocks = boondocks
            } catch let error {
                print("Error decoding boondocking locations. \(error) \(error.localizedDescription)")
            }
        }.resume()
    }
}
