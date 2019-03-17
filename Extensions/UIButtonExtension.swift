//
//  UIButtonExtension.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/10/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import UIKit

extension UIButton {
    func applyGreenTheme(buttonTitle: String?) {
        self.layer.cornerRadius = 0.0
        self.clipsToBounds = true
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.backgroundColor = UIColor(red: 0.0, green: 0.77, blue: 0.60, alpha: 1.0)
        self.setTitle(buttonTitle, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
    }
}
