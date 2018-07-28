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
        icon = UIImage(named: "campground_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}
