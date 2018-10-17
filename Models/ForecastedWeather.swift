/*
 ----------------------------------------------------------------------------------------
 
 ForecastedWeather.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 8/25/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Forecasted weather pulled from api.weather.gov
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

struct ForecastedWeatherData : Codable {
    let properties : Properties?
    
    enum CodingKeys: String, CodingKey {
        case properties = "properties"
    }
    
    struct Properties : Codable {
        let updated : String?
        let units : String?
        let forecastGenerator : String?
        let generatedAt : String?
        let updateTime : String?
        let validTimes : String?
        let elevation : Elevation?
        let periods : [Periods]?
        
        enum CodingKeys: String, CodingKey {
            
            case updated = "updated"
            case units = "units"
            case forecastGenerator = "forecastGenerator"
            case generatedAt = "generatedAt"
            case updateTime = "updateTime"
            case validTimes = "validTimes"
            case elevation = "elevation"
            case periods = "periods"
        }
    }
    
    struct Elevation : Codable {
        let value : Double?
        let unitCode : String?
        
        enum CodingKeys: String, CodingKey {
            
            case value = "value"
            case unitCode = "unitCode"
        }
    }
    
    struct Periods : Codable {
        let number : Int?
        let name : String?
        let startTime : String?
        let endTime : String?
        let isDaytime : Bool?
        let temperature : Int?
        let temperatureUnit : String?
        let temperatureTrend : String?
        let windSpeed : String?
        let windDirection : String?
        let icon : String?
        let shortForecast : String?
        let detailedForecast : String?
        
        enum CodingKeys: String, CodingKey {
            
            case number = "number"
            case name = "name"
            case startTime = "startTime"
            case endTime = "endTime"
            case isDaytime = "isDaytime"
            case temperature = "temperature"
            case temperatureUnit = "temperatureUnit"
            case temperatureTrend = "temperatureTrend"
            case windSpeed = "windSpeed"
            case windDirection = "windDirection"
            case icon = "icon"
            case shortForecast = "shortForecast"
            case detailedForecast = "detailedForecast"
        }
    }
}
