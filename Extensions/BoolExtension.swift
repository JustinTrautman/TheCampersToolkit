//
//  BoolExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/15/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import Foundation

extension Bool {
    /// Returns a yes or no string from a bool. Returns 'unknown' if value is nil.
    func amenityStatus() -> String {
        switch self {
        case true:
            return "yes"
        case false:
            return "no"
        default:
            return "unknown"
        }
    }
}

