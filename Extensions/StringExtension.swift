//
//  StringExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/11/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import Foundation

extension String {
    /// Returns a valid Google Photos Api url from a photo reference string.
    func googlePhotosUrl(photoRef: String, maxWidth: Int) -> URL {
        
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoRef)&key=\(Constants.googleApiKey)")!
    }
}

extension String {
    /// Returns a date value from a string in MMMM dd, yyyy
    var asDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.date(from: self)!
    }
    
    /// Returns a 'MMMM dd, yyyy' date from an Iso date in 'yyyy-MM-dd HH:mm:ss' format.
    var formatIsoDate: String {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
        guard let isoDate = isoFormatter.date(from: self) else {
            return "Invalid Date"
        }
        
        // Convert to a more readable format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: isoDate)
        return formattedDate
    }
}

extension String {
    /// Takes in a string and returns only digit values.
    var digitsOnly: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

