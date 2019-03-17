/*
 ----------------------------------------------------------------------------------------
 
 GoogleDetailController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/16/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Google Place Details API: https://developers.google.com/places/web-service/details
 Place Photos API: https://developers.google.com/places/web-service/photos
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class GoogleDetailController {
    
    static let detailsBaseURL = URL(string: "https://maps.googleapis.com/maps/api/place/details/json")
    static let photosBaseURL = URL(string: "https://maps.googleapis.com/maps/api/place/photo?")
    static let placeDetailFields = "formatted_address,opening_hours,photo,name,website,rating,price_level,review,formatted_phone_number"
    static var campgrounds: Result?
    static var reviews: [Reviews]?
    static var photos: [Photos] = []
    
    static func fetchPlaceDetailsWith(placeId: String, completion: @escaping ((Result)?) -> Void) {
        guard let url = detailsBaseURL else { completion(nil) ; return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let placeIdQuery = URLQueryItem(name: "placeid", value: placeId)
        let fieldsQuery = URLQueryItem(name: "fields", value: placeDetailFields)
        let apiKeyQuery = URLQueryItem(name: "key", value: Constants.googleApiKey)
        
        let queryArray = [placeIdQuery, fieldsQuery, apiKeyQuery]
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
                let campgrounds = try jsonDecoder.decode(CampgroundDetailData.self, from: data).result
                self.campgrounds = campgrounds
                completion(campgrounds)
            } catch let error {
                print("Error decoding Google Place data. Exiting with error: \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
    
    static func fetchReviewerProfilePhotoWith(photoUrl: String, completion: @escaping ((UIImage?)) -> Void) {
        guard let url = URL(string: photoUrl) else { completion(nil) ; return }
        
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
    
    static func fetchPlaceReviewsWith(placeId: String, completion: @escaping([Reviews]?) -> Void) {
        guard let url = detailsBaseURL else { completion(nil) ; return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let placeIdQuery = URLQueryItem(name: "placeid", value: placeId)
        let fieldsQuery = URLQueryItem(name: "fields", value: "review")
        let apiKeyQuery = URLQueryItem(name: "key", value: Constants.googleApiKey)
        
        let queryArray = [placeIdQuery, fieldsQuery, apiKeyQuery]
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
                let reviews = try jsonDecoder.decode(CampgroundDetailData.self, from: data).result.reviews
                self.reviews = reviews
                completion(reviews)
            } catch let error {
                print("Error decoding reviews. Exiting with error: \(error) \(error.localizedDescription)")
            }
            }.resume()
    }
    
//    static func fetchPlacePhotoWith(photoReference: String, completion: @escaping ((UIImage)?) -> Void) {
//        guard let url = photosBaseURL else { completion(nil) ; return }
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        
//        let photoreferenceQuery = URLQueryItem(name: "photoreference", value: photoReference)
//        let maxWidthQuery = URLQueryItem(name: "maxwidth", value: "700") // In pixels
//        let maxHeightQuery = URLQueryItem(name: "maxheight", value: "700")
//        let apiKeyQuery = URLQueryItem(name: "key", value: Constants.googleApiKey)
//        
//        let queryArray = [photoreferenceQuery, maxWidthQuery, maxHeightQuery, apiKeyQuery]
//        components?.queryItems = queryArray
//        
//        guard let completeURL = components?.url else { completion(nil) ; return }
//        
//        URLSession.shared.dataTask(with: completeURL) { (data, _, error) in
//            if let error = error {
//                print("DataTask had an issue reaching the network. Exiting with error: \(error) \(error.localizedDescription)")
//                completion(nil) ; return
//            }
//            
//            guard let data = data else { completion(nil) ; return }
//            
//            let image = UIImage(data: data)
//            completion(image)
//            }.resume()
//    }
}
