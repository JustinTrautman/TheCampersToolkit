/*
 ----------------------------------------------------------------------------------------
 
 BoondockingViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps

class BoondockingViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        openSearchWindow()
    }
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    var beenAlerted = UserDefaults.standard.bool(forKey: "Alerted")
    
    // MARK: - View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        if !beenAlerted {
            AlertHelper.showAgreementAlert(on: self) // User must agree to accuracy terms before using.
            
            UserDefaults.standard.setValue("True", forKey: "Alerted")
            UserDefaults.standard.synchronize()
            
            fetchBoondockingLocations()
        }
        
        // If user has already agreed, fetch locations
        fetchBoondockingLocations()
    }
    
    func openSearchWindow() {
        let searchWindow = UIAlertController(title: nil, message: "Enter a city or state to locate boondocking locations", preferredStyle: .alert)
        
        var searchTextField: UITextField?
        
        searchWindow.addTextField { (textField) in
            searchTextField?.placeholder = "Search any location"
            searchTextField = textField
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { (search) in
            guard let searchText = searchTextField?.text, !searchText.isEmpty else { return }
            self.navigationBar.title = searchText
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
                
                let latitude = location.latitude
                let longitude = location.longitude
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 7, bearing: 0, viewingAngle: 0)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        searchWindow.addAction(cancelAction)
        searchWindow.addAction(searchAction)
        
        self.present(searchWindow, animated: true)
    }
    
    func fetchBoondockingLocations() {
        BoondockingController.fetchAllBoondockingLocations { (boondocking) in
            if let foundBoondocks = boondocking {
                let usersLocation = self.locationManager.location?.coordinate
                let coordinates = CLLocationCoordinate2D(latitude: usersLocation?.latitude ?? 0, longitude: usersLocation?.longitude ?? 0)
                self.boondockingLocations = foundBoondocks
                
                DispatchQueue.main.async {
                    for boondock in foundBoondocks {
                        let marker = BoondockingMarker(boondocking: [boondock])
                        
                        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 7, bearing: 0, viewingAngle: 0)
                        
                        marker.map = self.mapView
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
        guard let location = locations.first else { return }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
        fetchBoondockingLocations()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let boondockingMarker = marker as? BoondockingMarker,
            let infoView = UIView.viewFromNibName("BoondockingMarkerView") as? BoondockingMarkerView else {
                return nil
        }
        
        let boondocks = boondockingMarker.boondocking
        
        for boondock in boondocks {
            infoView.descriptionLabel.text = boondock.description
            
            guard let latitude = boondock.latitude,
                let longitude = boondock.longitude else {
                    return  UIView()
            }
            
            let latitudeAsDouble = Double("\(latitude)") ?? 0
            let longitudeAsDouble = Double("\(longitude)") ?? 0
            let usersLocation = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
            let destination = CLLocation(latitude: latitudeAsDouble, longitude: longitudeAsDouble)
            let distanceInMeters = destination.distance(from: usersLocation)
            let distanceInMiles = Double(distanceInMeters) * 0.000621371
            
            infoView.milesAwayLabel.text = "\(distanceInMiles.roundToPlaces(places: 2)) miles away"
            
            selectedBoondock = boondock
        }
        
        return infoView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBoondockDetail" {
            guard let detailVC = segue.destination as? BoondockingDetailViewController else { return }
            
            detailVC.boondockingLocations = boondockingLocations
            detailVC.selectedBoondock = selectedBoondock
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: "toBoondockDetail", sender: BoondockingMarker.self)
    }
}

