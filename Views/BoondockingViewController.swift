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

class BoondockingViewController: UIViewController, WKNavigationDelegate {
    
//    // MARK: Properties
//    var webView: WKWebView!
//    var beenAlerted: Bool = false
//    
//    override func loadView() {
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        view = webView
//
//        if !beenAlerted {
//            showAccuracyAlert() // User must agree to accuracy terms before using.
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let url = URL(string: "https://drive.google.com/open?id=1X961m_UTUq8piVbRbB8btwbQQM4mUQ4T&usp=sharing")!
//        webView.load(URLRequest(url: url))
//
//        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
//        toolbarItems = [refresh]
//        navigationController?.isToolbarHidden = false
//    }
//
//    func showAccuracyAlert() {
//        let accuracyAlert = UIAlertController(title: nil, message: "The Camper's Toolkit cannot guarentee the accuracy of all boondocking information and locations. Always check with the site owner to verify boondocking is allowed", preferredStyle: .alert)
//
//        let iAgreeAction = UIAlertAction(title: "I Agree", style: .default, handler: nil)
//
//        accuracyAlert.addAction(iAgreeAction)
//        self.present(accuracyAlert, animated: true)
//
//        beenAlerted = true
//    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    var boondockingLocations: [Boondocking]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
         fetchBoondockingLocations()
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
        guard let placeMarker = marker as? PlaceMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("CampgroundMarkerView") as? CampgroundMarkerView else {
            return nil
        }
        
        infoView.nameLabel.text = "name"
        if let photo = UIImage(named: "campground_pin") {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "campground_pin")
        }
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}
