/*
 ----------------------------------------------------------------------------------------
 
 BoondockingViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 TODO: - Version 1.5 replace webview with custom API on Firebase.
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import WebKit
import GoogleMaps

class BoondockingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    var beenAlerted: Bool = false
    
    // MARK: - View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        if !beenAlerted {
            showToSAlert() // User must agree to accuracy terms before using.
            
            fetchBoondockingLocations()
        }
    }
    
    func fetchBoondockingLocations() {
        BoondockingController.fetchAllBoondockingLocations { (boondocking) in
            if let boondocking = boondocking {
                let coordinates = CLLocationCoordinate2D(latitude: 39.828175, longitude: -98.5795)
                self.boondockingLocations = boondocking
                
                DispatchQueue.main.async {
                    for boondocks in boondocking {
                        let marker = BoondockingMarker(boondocking: [boondocks])
                        marker.map = self.mapView
                        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 3, bearing: 0, viewingAngle: 0)
                    }
                }
            }
        }
    }
    
    func showToSAlert() {
        let accuracyAlert = UIAlertController(title: nil, message: "By using the boondocking feature of this app you understand and agree to the ToS in the information section of this screen.", preferredStyle: .alert)
        
        let understandAction = UIAlertAction(title: "I Understand", style: .default, handler: nil)
        
        accuracyAlert.addAction(understandAction)
        self.present(accuracyAlert, animated: true)
        
        beenAlerted = true
    }
}

extension BoondockingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        fetchBoondockingLocations()
    }
}

extension BoondockingViewController: GMSMapViewDelegate {
    
    // MARK: - Marker Cluster
    //    class POItem: NSObject, GMUClusterItem {
    //
    //
    //    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? BoondockingMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("BoondockingMarkerView") as? BoondockingMarkerView else {
            return nil
        }
        
        for boondock in placeMarker.boondocking {
            infoView.descriptionLabel.text = boondock.description
            
            guard let latitude = boondock.latitude,
                let longitude = boondock.longitude else { return  UIView() }
            
            let latitudeInDouble = Double("\(latitude)") ?? 0
            let longitudeInDouble = Double("\(longitude)") ?? 0
            print(latitudeInDouble)
            print(longitudeInDouble)
            
                    let coordinates = CLLocationCoordinate2D(latitude: latitudeInDouble, longitude: longitudeInDouble)
            
            selectedBoondock = boondock

                    let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 14)
                    infoView.boondockingMapView.camera = camera
                    infoView.boondockingMapView.mapType = GMSMapViewType.satellite
                }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBoondockDetail" {
            guard let detailVC = segue.destination as? BoondockingDetailViewController else { return }
            
            // TODO: - Pass information to detail VC
            detailVC.boondockingLocations = boondockingLocations
            detailVC.selectedBoondock = selectedBoondock
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let boondockMarker = marker as? BoondockingMarker
        performSegue(withIdentifier: "toBoondockDetail", sender: BoondockingMarker.self)
    }
}
