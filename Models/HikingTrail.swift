/*
 ----------------------------------------------------------------------------------------
 
 HikingTrail.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/23/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Hiking trail data pulled from: https://www.hikingproject.com/data
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct HikingTrailData : Codable {
    
    let trails : [Trails]
    let success : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case trails = "trails"
        case success = "success"
    }
}
    
    struct Trails : Codable {
        
        let id : Int?
        let name : String?
        let type : String?
        let summary : String?
        let difficulty : String?
        let stars : Double?
        let starVotes : Int?
        let location : String?
        let url : String?
        let imgSqSmall : String?
        let imgSmall : String?
        let imgSmallMed : String?
        let imgMedium : String?
        let length : Double?
        let ascent : Int?
        let descent : Int?
        let high : Int?
        let low : Int?
        let longitude : Double?
        let latitude : Double?
        let conditionStatus : String?
        let conditionDetails : String?
        let conditionDate : String?
        
        enum CodingKeys: String, CodingKey {
            
            case id = "id"
            case name = "name"
            case type = "type"
            case summary = "summary"
            case difficulty = "difficulty"
            case stars = "stars"
            case starVotes = "starVotes"
            case location = "location"
            case url = "url"
            case imgSqSmall = "imgSqSmall"
            case imgSmall = "imgSmall"
            case imgSmallMed = "imgSmallMed"
            case imgMedium = "imgMedium"
            case length = "length"
            case ascent = "ascent"
            case descent = "descent"
            case high = "high"
            case low = "low"
            case longitude = "longitude"
            case latitude = "latitude"
            case conditionStatus = "conditionStatus"
            case conditionDetails = "conditionDetails"
            case conditionDate = "conditionDate"
    }
}
