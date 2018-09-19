/*
 ----------------------------------------------------------------------------------------
 
 GoogleDetail.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/16/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Campground Detail Data pulled from Google Place Details API:
 https://developers.google.com/places/web-service/details
 
 ----------------------------------------------------------------------------------------
 */


import Foundation

struct CampgroundDetailData : Codable {
    let result : Result
}

struct Result : Codable {
    let formattedAddress : String?
    let formattedPhoneNumber : String?
    let name : String?
    let openingHours : OpeningHours?
    let photos : [Photos]?
    let rating : Double?
    let reviews : [Reviews]?
    let website : String?
    let geometry: Geometry?
    let priceLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case name
        case openingHours = "opening_hours"
        case photos = "photos"
        case rating
        case reviews = "reviews"
        case website, geometry
        case priceLevel = "price_level"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        formattedAddress = try values.decodeIfPresent(String.self, forKey: .formattedAddress)
        formattedPhoneNumber = try values.decodeIfPresent(String.self, forKey: .formattedPhoneNumber)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        openingHours = try values.decodeIfPresent(OpeningHours.self, forKey: .openingHours)
        photos = try values.decodeIfPresent([Photos].self, forKey: .photos)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        reviews = try values.decodeIfPresent([Reviews].self, forKey: .reviews)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        geometry = try values.decodeIfPresent(Geometry.self, forKey: .geometry)
        priceLevel = try values.decodeIfPresent(Int.self, forKey: .priceLevel)
    }
}

struct OpeningHours : Codable {
    let openNow : Bool?
    let periods : [Periods]?
    let weekdayText : [String]?
    
    enum CodingKeys: String, CodingKey {
        
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        openNow = try values.decodeIfPresent(Bool.self, forKey: .openNow)
        periods = try values.decodeIfPresent([Periods].self, forKey: .periods)
        weekdayText = try values.decodeIfPresent([String].self, forKey: .weekdayText)
    }
}

struct Periods : Codable {
    let close : Close?
    let open : Open?
    
    enum CodingKeys: String, CodingKey {
        
        case close, open
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        close = try values.decodeIfPresent(Close.self, forKey: .close)
        open = try values.decodeIfPresent(Open.self, forKey: .open)
    }
}

struct Close : Codable {
    let day : Int?
    let time : String?
    
    enum CodingKeys: String, CodingKey {
        
        case day, time
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = try values.decodeIfPresent(Int.self, forKey: .day)
        time = try values.decodeIfPresent(String.self, forKey: .time)
    }
}

struct Open : Codable {
    let day : Int?
    let time : String?
    
    enum CodingKeys: String, CodingKey {
        
        case day, time
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = try values.decodeIfPresent(Int.self, forKey: .day)
        time = try values.decodeIfPresent(String.self, forKey: .time)
    }
}

struct Photos : Codable {
    let height : Int?
    let htmlAttributions : [String]?
    let photoReference : String?
    let width : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        height = try values.decodeIfPresent(Int.self, forKey: .height)
        htmlAttributions = try values.decodeIfPresent([String].self, forKey: .htmlAttributions)
        photoReference = try values.decodeIfPresent(String.self, forKey: .photoReference)
        width = try values.decodeIfPresent(Int.self, forKey: .width)
    }
}

struct Reviews : Codable {
    let authorName : String?
    let authorUrl : String?
    let language : String?
    let profilePhotoUrl : String?
    let rating : Int?
    let relativeTimeDescription : String?
    let text : String?
    
    enum CodingKeys: String, CodingKey {
        
        case authorName = "author_name"
        case authorUrl = "author_url"
        case language = "language"
        case profilePhotoUrl = "profile_photo_url"
        case rating
        case relativeTimeDescription = "relative_time_description"
        case text
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authorName = try values.decodeIfPresent(String.self, forKey: .authorName)
        authorUrl = try values.decodeIfPresent(String.self, forKey: .authorUrl)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        profilePhotoUrl = try values.decodeIfPresent(String.self, forKey: .profilePhotoUrl)
        rating = try values.decodeIfPresent(Int.self, forKey: .rating)
        relativeTimeDescription = try values.decodeIfPresent(String.self, forKey: .relativeTimeDescription)
        text = try values.decodeIfPresent(String.self, forKey: .text)
    }
}
