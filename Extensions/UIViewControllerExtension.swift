//
//  UIViewControllerExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/13/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Returns a 'toClassName' string for segue identifiers
    class var segueIdentifier: String {
        return String(describing: "to\(self)")
    }
}
