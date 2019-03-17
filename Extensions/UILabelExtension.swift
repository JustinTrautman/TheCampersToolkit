//
//  UILabelExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/13/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setHeight(parentView: UIView) {
        self.frame = CGRect(x: 0, y: 0, width: parentView.bounds.width, height: 0)
        self.sizeToFit()
        self.frame.size = self.bounds.size
    }
}
