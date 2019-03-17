//
//  AppUpdate.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 11/15/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

class LookupResult: Decodable {
    var results: [AppInfo]
}

class AppInfo: Decodable {
    var version: String
}
