/*
 ----------------------------------------------------------------------------------------
 
 CustomMarker.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/16/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Custom marker classes that contain logic for the Campground, Boondocking, and Travel
 view controller annotations.
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps

class CampgroundMarker: GMSMarker {
    
    let place: Results
    
    init(place: Results) {
        self.place = place
        super.init()
        
        let coordinates = CLLocationCoordinate2D(latitude: place.geometry?.location?.lat ?? 0, longitude: place.geometry?.location?.lng ?? 0)
        let selectedType = GooglePlaceSearchController.selectedType ?? ""
        
        position = coordinates
        icon = UIImage(named: selectedType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1.0)
        appearAnimation = .pop
    }
}

class AmenityMarker: GMSMarker {
    
    let googlePlace: Results
    
    init(googlePlace: Results) {
        self.googlePlace = googlePlace
        super.init()
        
        guard let latitude = googlePlace.geometry?.location?.lat,
            let longitude = googlePlace.geometry?.location?.lng else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        position = coordinates
        
        guard let selectedType = GooglePlaceSearchController.selectedType else { print("Couldn't identify selected type") ; return }
        icon = UIImage(named: "\(selectedType)"+"_pin")
        
        groundAnchor = CGPoint(x: 0.5, y: 1.0)
        appearAnimation = .pop
    }
}

class BoondockingMarker: GMSMarker {
    
    let boondocking: [Boondocking]
    
    init(boondocking: [Boondocking]) {
        self.boondocking = boondocking
        super.init()
        
        for boondocks in boondocking {
            guard let latitude = boondocks.latitude,
                let longitude = boondocks.longitude else { return }
            
            if let lat = Double(latitude) {
                if let lon = Double(longitude) {
                    
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    position = coordinates
                }
            }
        }
        icon = UIImage(named: "boondocking_pin")
        
        groundAnchor = CGPoint(x: 0.5, y: 1.0)
        appearAnimation = .pop
    }
}
