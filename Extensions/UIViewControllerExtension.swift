//
//  UIViewControllerExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 12/11/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Returns a 'toClassName' String for identifying segues
    class var segueIdentifier: String {
        return String(describing: "to\(self)")
    }
}
