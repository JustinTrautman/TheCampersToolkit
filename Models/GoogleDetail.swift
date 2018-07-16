//
//  GoogleDetail.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/16/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

struct Result : Codable {
    let campgroundName: String
    let campgroundRating: Double?
    let reviews: [Reviews]?
    
    enum CodingKeys: String, CodingKey {
        case campgroundName = "name"
        case campgroundRating = "rating"
        case reviews
    }
}

struct Reviews : Codable {
    let authorName: String
    let authorURL: String?
    let profilePhotoURL: String?
    let rating: Int
    let reviewWrittenDate: String
    let reviewText: String
    
    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case authorURL = "author_url"
        case profilePhotoURL = "profile_photo_url"
        case rating
        case reviewWrittenDate = "relative_time_description"
        case reviewText = "text"
    }
}
