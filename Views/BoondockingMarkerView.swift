/*
 ----------------------------------------------------------------------------------------
 
 BoondockingMarkerView.swift
 TheCampersToolkit

 Created by Justin Trautman on 9/23/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps

class BoondockingMarkerView: UIView, GMSMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var milesAwayLabel: UILabel!
}
