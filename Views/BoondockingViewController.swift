//
//  BoondockingViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/13/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit
import GooglePlacePicker
import GoogleMaps
import GooglePlaces

class PlacePickerVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblAddress:UILabel!
    @IBOutlet var lblLatitude:UILabel!
    @IBOutlet var lblLongitude:UILabel!
    @IBOutlet var indicatorView:UIActivityIndicatorView!
    
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getPlacePickerView()
        
    }
    func getPlacePickerView() {
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
}

extension PlacePickerVC : GMSPlacePickerViewControllerDelegate
{
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        self.viewContainer.isHidden = false
        self.indicatorView.isHidden = true
        
        viewController.dismiss(animated: true, completion: nil)
        
        self.lblName.text = place.name
        self.lblAddress.text = place.formattedAddress?.components(separatedBy: ", ")
            .joined(separator: "\n")
        self.lblLatitude.text = String(place.coordinate.latitude)
        self.lblLongitude.text = String(place.coordinate.longitude)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        self.viewContainer.isHidden = true
        self.indicatorView.isHidden = true
    }
}
