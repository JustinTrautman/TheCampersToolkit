/*
 ----------------------------------------------------------------------------------------
 
 CurrentWeather.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net

 Current weather data pulled from https://openweathermap.org/
 Weather types:
 * Drizzle
 * Clear
 * Haze
 * Thunderstorm
 * Snow? - Check if type
 * Rain
 * Mist
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct CampgroundWeatherData : Codable {
    let coord : Coord?
    let weather : [Weather]?
    let base : String?
    let main : Main?
    let visibility : Int?
    let wind : Wind?
    let clouds : Clouds?
    let dt : Int?
    let sys : Sys?
    let id : Int?
    let name : String?
    let cod : Double?
    
    enum CodingKeys: String, CodingKey {
        
        case coord = "coord"
        case weather = "weather"
        case base = "base"
        case main = "main"
        case visibility = "visibility"
        case wind = "wind"
        case clouds = "clouds"
        case dt = "dt"
        case sys = "sys"
        case id = "id"
        case name = "name"
        case cod = "cod"
    }
}

struct Coord : Codable {
    let lon : Double?
    let lat : Double?
    
    enum CodingKeys: String, CodingKey {
        
        case lon = "lon"
        case lat = "lat"
    }
}

struct Weather : Codable {
    let id : Int?
    let main : String?
    let description : String?
    let icon : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case main = "main"
        case description = "description"
        case icon = "icon"
    }
}

struct Main : Codable {
    let temp : Double?
    let pressure : Double?
    let humidity : Double?
    let tempMin : Double?
    let tempMax : Double?
    
    enum CodingKeys: String, CodingKey {
        
        case temp = "temp"
        case pressure = "pressure"
        case humidity = "humidity"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Wind : Codable {
    let speed : Double?
    let windDirection : Double?
    let gust : Double?
    
    enum CodingKeys: String, CodingKey {
        
        case speed = "speed"
        case windDirection = "deg"
        case gust = "gust"
    }
}

struct Clouds : Codable {
    let all : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case all = "all"
    }
}

struct Sys : Codable {
    let type : Int?
    let id : Int?
    let message : Double?
    let country : String?
    let sunrise : Int?
    let sunset : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case type = "type"
        case id = "id"
        case message = "message"
        case country = "country"
        case sunrise = "sunrise"
        case sunset = "sunset"
    }
}
