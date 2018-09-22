/*
 ----------------------------------------------------------------------------------------
 
 PlaceMarker.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/16/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net

 ----------------------------------------------------------------------------------------
 */


import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
    let place: GooglePlace

    init(place: GooglePlace) {
        self.place = place
        super.init()

        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}

class AmmenityMarker: GMSMarker {
    
    let googlePlace: Results
    
    init(googlePlace: Results) {
        self.googlePlace = googlePlace
        super.init()
        
        guard let latitude = googlePlace.geometry?.location?.lat,
            let longitude = googlePlace.geometry?.location?.lng else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        position = coordinates
        
        icon = UIImage(named: "gas_station_pin")
//        icon = UIImage(named: googlePlace.placeType+"_pin")
        
        groundAnchor = CGPoint(x: 0.5, y: 1)
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
                    
                    print("\(lat),\(lon)")
                    
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    position = coordinates
                }
            }
        }
        icon = UIImage(named: "boondocking_pin")
        
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}
