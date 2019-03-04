/*
 ----------------------------------------------------------------------------------------
 
 DoubleExtension.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 8/2/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 Extends Double and limits decimal places to a specified number. Used on Google map pins
 when showing the driving distance from the user.
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

extension Double {
    func roundToPlaces(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundToClosestHalf() -> Double {
        return Double(Int(self * 2)) / 2
    }
}
