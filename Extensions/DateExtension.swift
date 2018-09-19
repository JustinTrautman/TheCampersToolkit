//
//  DateExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/15/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

extension Date {
    
    // Returns an integer from 1 - 7 with 1 being Sunday and 7 being Saturday
    func dayOfWeekInteger() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
