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
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    var beenAlerted = UserDefaults.standard.bool(forKey: "Alerted")
    
    // MARK: - View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        if !beenAlerted {
            showToSAlert() // User must agree to accuracy terms before using.
            
            UserDefaults.standard.setValue("True", forKey: "Alerted")
            UserDefaults.standard.synchronize()
            
            fetchBoondockingLocations()
        }
        
        // If user has already agreed, fetch locations
        fetchBoondockingLocations()
    }
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        openSearchWindow()
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
            
            print("I am now searching for boondocking locations in \(searchText)")
            
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
            if let boondocking = boondocking {
                let usersLocation = self.locationManager.location?.coordinate
                let coordinates = CLLocationCoordinate2D(latitude: usersLocation?.latitude ?? 0, longitude: usersLocation?.longitude ?? 0)
                self.boondockingLocations = boondocking
                
                DispatchQueue.main.async {
                    for boondocks in boondocking {
                        let marker = BoondockingMarker(boondocking: [boondocks])
                        
                        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 7, bearing: 0, viewingAngle: 0)
                        guard let latitude = boondocks.latitude,
                            let longitude = boondocks.longitude else { return }
                        let latAsDouble = Double("\(latitude)")
                        let lonAsDouble = Double("\(longitude)")
                        
                        let coordinates = CLLocationCoordinate2D(latitude: latAsDouble ?? 0, longitude: lonAsDouble ?? 0)
                        
                        marker.map = self.mapView
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
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let boondockingMarker = marker as? BoondockingMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("BoondockingMarkerView") as? BoondockingMarkerView else {
            return nil
        }
        
        for boondock in boondockingMarker.boondocking {
            infoView.descriptionLabel.text = boondock.description
            
            guard let latitude = boondock.latitude,
                let longitude = boondock.longitude else { return  UIView() }
            
            let latitudeInDouble = Double("\(latitude)") ?? 0
            let longitudeInDouble = Double("\(longitude)") ?? 0
            print(latitudeInDouble)
            print(longitudeInDouble)
            
            let usersLocation = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
            let destination = CLLocation(latitude: latitudeInDouble, longitude: longitudeInDouble)
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

