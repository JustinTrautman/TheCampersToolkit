/*
 ----------------------------------------------------------------------------------------
 
 Boondocking.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/27/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Boondocking locations pulled from custom Firebase RESTful API
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct Boondocking : Codable {
    let dateLastUpdated : String?
    let description : String?
    let website: String?
    let phone: String?
    let fireRing : Bool?
    let flat : Bool?
    let flushToilet : Bool?
    let grill : Bool?
    let latitude : Double?
    let length : Double?
    let longitude : Double?
    let nonPotableWater : Bool?
    let poiid : Int?
    let picnicTable : Bool?
    let pitToilet : Bool?
    let potableWater : Bool?
    let registrationRequired : Bool?
    let width : Double?
    
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
        case poiid = "POIID"
        case picnicTable = "PicnicTable"
        case pitToilet = "PitToilet"
        case potableWater = "PotableWater"
        case registrationRequired = "RegistrationRequired"
        case width = "Width"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dateLastUpdated = try values.decodeIfPresent(String.self, forKey: .dateLastUpdated)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        fireRing = try values.decodeIfPresent(Bool.self, forKey: .fireRing)
        flat = try values.decodeIfPresent(Bool.self, forKey: .flat)
        flushToilet = try values.decodeIfPresent(Bool.self, forKey: .flushToilet)
        grill = try values.decodeIfPresent(Bool.self, forKey: .grill)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        length = try values.decodeIfPresent(Double.self, forKey: .length)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        nonPotableWater = try values.decodeIfPresent(Bool.self, forKey: .nonPotableWater)
        poiid = try values.decodeIfPresent(Int.self, forKey: .poiid)
        picnicTable = try values.decodeIfPresent(Bool.self, forKey: .picnicTable)
        pitToilet = try values.decodeIfPresent(Bool.self, forKey: .pitToilet)
        potableWater = try values.decodeIfPresent(Bool.self, forKey: .potableWater)
        registrationRequired = try values.decodeIfPresent(Bool.self, forKey: .registrationRequired)
        width = try values.decodeIfPresent(Double.self, forKey: .width)
    }
}
