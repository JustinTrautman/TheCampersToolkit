//
//  BoondockingMarkerView.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/23/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit
import GoogleMaps

class BoondockingMarkerView: UIView, GMSMapViewDelegate {
    
    override func awakeFromNib() {
        setupMapView()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var boondockingMapView: GMSMapView!
    
    func setupMapView() {
        boondockingMapView.delegate = self
        
        let coordinates = CLLocationCoordinate2D(latitude: 44.6368, longitude: -124.0535)
        
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 14)
        boondockingMapView.camera = camera
        boondockingMapView.mapType = GMSMapViewType.normal
    }
}
