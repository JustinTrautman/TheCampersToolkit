//
//  Boondocking.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/27/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

struct Boondocking : Codable {
    
    let dateLastUpdated : String?
    let description : String?
    let fireRing : String?
    let flat : String?
    let flushToilet : String?
    let grill : String?
    let latitude : String?
    let length : String?
    let longitude : String?
    let nonPotableWater : String?
    let pOIID : String?
    let picnicTable : String?
    let pitToilet : String?
    let portableWater : String?
    let registrationRequired : String?
    let width : String?
    
    enum CodingKeys: String, CodingKey {
        
        case dateLastUpdated = "DateLastUpdated"
        case description = "Description"
        case fireRing = "FireRing"
        case flat = "Flat"
        case flushToilet = "FlushToilet"
        case grill = "Grill"
        case latitude = "Latitude"
        case length = "Length"
        case longitude = "Longitude"
        case nonPotableWater = "NonPotableWater"
        case pOIID = "POIID"
        case picnicTable = "PicnicTable"
        case pitToilet = "PitToilet"
        case portableWater = "PortableWater"
        case registrationRequired = "RegistrationRequired"
        case width = "Width"
    }
}
