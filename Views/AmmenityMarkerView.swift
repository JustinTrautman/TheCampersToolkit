//
//  AmmenityMarkerView.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/11/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class AmmenityMarkerView: UIView {
    
    static let shared = AmmenityMarkerView()
    
    // MARK: - Outlets
    @IBOutlet weak var ammenityNameLabel: UILabel!
    @IBOutlet weak var ammenityImageView: UIImageView!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var priceLevelLabel: UILabel!
}
