/*
 ----------------------------------------------------------------------------------------
 
 WeatherEnum.swift
 TheCampersToolkit

 Created by Justin Trautman on 10/7/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Enum that handles different cases on the WeatherViewController. 
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

enum WeatherType : String {
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

enum TemperatureRange : Double {
    case highTemp = 90.0
    case lowTemp = 60.0
    case coldTem = 32.0
}

//enum WindSpeed : Int {
//
//}

enum AmenitySegue : String {
    case gasMap = "toGasMap"
    case propaneMap = "toPropaneMap"
    case storeMap = "toStoreMap"
    case carRepairMap = "toCarRepairMap"
}

enum DayOfTheWeek : String {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

enum IsOpen : String {
    case open = "true"
    case closed = "false"
    case empty = ""
}

