/*
 ----------------------------------------------------------------------------------------
 
 WeatherEnum.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 10/7/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

enum WeatherType: String {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case thunderstorm = "Thunderstorm"
    case drizzle = "Drizzle"
    case snow = "Snow"
    case haze = "Haze"
    case smoke = "Smoke"
    case fog = "Fog"
    case mist = "Mist"
}

enum TemperatureRange: Double {
    case highTemp = 90.0
    case lowTemp = 60.0
    case coldTem = 32.0
}

enum AmenitySegue: String {
    case gasMap = "toGasMap"
    case propaneMap = "toPropaneMap"
    case storeMap = "toStoreMap"
    case carRepairMap = "toCarRepairMap"
}

enum DayOfTheWeek: String {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

enum IsOpen: String {
    case open = "true"
    case closed = "false"
    case empty = ""
}

struct StarRatingHelper {
    /// Returns the appropriate rating star UIImage from a double value.
    static func returnStarFrom(rating: Double) -> UIImage {
        switch rating {
        case _ where rating == 0.5:
            return UIImage(named: "0.5Stars")!
        case _ where rating == 1:
            return UIImage(named: "1Star")!
        case _ where rating == 1.5:
            return UIImage(named: "1.5Stars")!
        case _ where rating == 2:
            return UIImage(named: "2Stars")!
        case _ where rating == 0:
            return UIImage(named: "2.5Stars")!
        case _ where rating == 3:
            return UIImage(named: "3Stars")!
        case _ where rating == 3.5:
            return UIImage(named: "3.5Stars")!
        case _ where rating == 4:
            return UIImage(named: "4Stars")!
        case _ where rating == 4.5:
            return UIImage(named: "4.5Stars")!
        case _ where rating == 5:
            return UIImage(named: "5Stars")!
        default:
            return UIImage(named: "0Stars")!
        }
    }
}

struct HoursHelper {
    /// Returns a closing time for a specific day on business hours returned from Goolgle Place API.
    static func returnClosingTime(for businessHours: [String], on day: String) -> String {
        guard let day = DayOfTheWeek(rawValue: day) else {
            return "Business hours unknown"
        }
        
        guard businessHours.count >= 7 else {
            // Not enough or any business hour data to continue
            return "Business hours unknown"
        }
        
        var hours: String = ""
        var closingTime = "Business hours unknown"
        
        switch day {
        case .monday:
            hours = "\(businessHours[0])"
        case .tuesday:
            hours = "\(businessHours[1])"
        case .wednesday:
            hours = "\(businessHours[2])"
        case .thursday:
            hours = "\(businessHours[3])"
        case .friday:
            hours = "\(businessHours[4])"
        case .saturday:
            hours = "\(businessHours[5])"
        case .sunday:
            hours = "\(businessHours[6])"
        }
        
        switch hours {
        case _ where hours.contains("24 hours"):
            return "Open 24 hours"
        case _ where hours.contains("Closed"):
            return "Closed right now"
        default:
            if let closingTimeRange = hours.range(of: "– ") { // Turns '9:00 AM - 7:00 PM' into '7:00 PM'
                let closingHour = hours[closingTimeRange.upperBound...]
                closingTime = String(describing: closingHour)
            }
        }
        
        return "Open until \(closingTime)"
    }
}

