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
    let website: String?
    let phone: String?
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
        case website = "Website"
        case phone = "Phone"
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dateLastUpdated = try values.decodeIfPresent(String.self, forKey: .dateLastUpdated)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        fireRing = try values.decodeIfPresent(String.self, forKey: .fireRing)
        flat = try values.decodeIfPresent(String.self, forKey: .flat)
        flushToilet = try values.decodeIfPresent(String.self, forKey: .flushToilet)
        grill = try values.decodeIfPresent(String.self, forKey: .grill)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        length = try values.decodeIfPresent(String.self, forKey: .length)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
        nonPotableWater = try values.decodeIfPresent(String.self, forKey: .nonPotableWater)
        pOIID = try values.decodeIfPresent(String.self, forKey: .pOIID)
        picnicTable = try values.decodeIfPresent(String.self, forKey: .picnicTable)
        pitToilet = try values.decodeIfPresent(String.self, forKey: .pitToilet)
        portableWater = try values.decodeIfPresent(String.self, forKey: .portableWater)
        registrationRequired = try values.decodeIfPresent(String.self, forKey: .registrationRequired)
        width = try values.decodeIfPresent(String.self, forKey: .width)
    }
}
