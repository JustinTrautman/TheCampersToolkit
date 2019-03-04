//
//  DateExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 12/12/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
