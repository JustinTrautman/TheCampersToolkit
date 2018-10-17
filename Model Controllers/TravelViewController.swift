/*
 ----------------------------------------------------------------------------------------
 
 TravelViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/28/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import CoreLocation

class TravelViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var gasStationButton: UIButton!
    @IBOutlet weak var propaneButton: UIButton!
    @IBOutlet weak var supermarketButton: UIButton!
    @IBOutlet weak var carRepairButton: UIButton!
    
    // MARK: - Properties
    var selectedType = ""
    var amenityMarker: AmenityMarker?
    var campgroundCoordinates: CLLocationCoordinate2D?
    var campgroundAmmenities: Bool = false
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? AmenityMapViewController else { return }
        
        guard let segueToPrepare = AmenitySegue(rawValue: segue.identifier ?? "") else { return }
        
        switch segueToPrepare {
        case .gasMap:
            selectedType = "gas_station"
        case .propaneMap:
            selectedType = "store"
        case .storeMap:
            selectedType = "supermarket"
        case .carRepairMap:
            selectedType = "car_repair"
        }
        
        detailVC.selectedType = selectedType
        
        if campgroundAmmenities == true {
            detailVC.campgroundCoordinates = campgroundCoordinates
        }
    }
}
