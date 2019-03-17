//
//  UITableViewCellExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 12/10/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

extension UITableViewCell {
    /// Returns a String representation of this class
    class var identifier: String {
        return String(describing: self)
    }
}
