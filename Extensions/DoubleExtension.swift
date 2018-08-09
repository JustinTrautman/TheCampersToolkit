//
//  DoubleExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 8/2/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

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
