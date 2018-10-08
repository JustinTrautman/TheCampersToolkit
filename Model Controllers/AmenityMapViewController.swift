/*
 ----------------------------------------------------------------------------------------
 
 TravelMapViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/28/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class AmenityMapViewController: UIViewController {
    
    static let shared = AmenityMapViewController()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properties
    private var locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private var searchRadius: Double = 8047
    
    var selectedType: String?
    var results: [Results]?
    var selectedAmmenity: String?
    var campgroundCoordinates: CLLocationCoordinate2D?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedType = selectedType else { return }
        print("Searching for \(selectedType)")
        
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        guard let selectedType = self.selectedType else { return }
        
        var coordinates = coordinate
        
        if campgroundCoordinates != nil {
            coordinates = campgroundCoordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        GooglePlaceSearchController.fetchPlacesNearby(latitude: "\(coordinates.latitude)", longitude: "\(coordinates.longitude)", radius: searchRadius, type: selectedType) { (places) in
            
            if let places = places {
                DispatchQueue.main.async {
                    for place in places {
                        let marker = AmmenityMarker(googlePlace: place)
                        marker.map = self.mapView
                        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 13, bearing: 0, viewingAngle: 0)
                        self.results = places
                    }
                }
                
                if places.count == 0 {
                    self.showNoAmenitiesAlert()
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func searchRadiusButtonTapped(_ sender: Any) {
        let searchRadiusActionSheet = UIAlertController(title: "Search Radius", message: nil, preferredStyle: .actionSheet)
        searchRadiusActionSheet.view.tintColor = .blue
        
        let fiveMileRadius = UIAlertAction(title: "5 Miles", style: .default) { (five) in
            self.searchRadius = 8047
           self.fetchNearbyPlaces(coordinate: self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        
        let tenMileRadius = UIAlertAction(title: "10 Miles", style: .default) { (twenty) in
            self.searchRadius = 16092
            self.fetchNearbyPlaces(coordinate: self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        
        let twentyMileRadius = UIAlertAction(title: "20 Miles", style: .default) { (fifty) in
            self.searchRadius = 32187
            self.fetchNearbyPlaces(coordinate: self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if searchRadius == 8047 {
            fiveMileRadius.isEnabled = false
        }
        
        if searchRadius == 16092 {
            tenMileRadius.isEnabled = false
        }
        
        if searchRadius == 50000 {
            twentyMileRadius.isEnabled = false
        }
        
        searchRadiusActionSheet.addAction(cancelAction)
        searchRadiusActionSheet.addAction(fiveMileRadius)
        searchRadiusActionSheet.addAction(tenMileRadius)
        searchRadiusActionSheet.addAction(twentyMileRadius)
        
        present(searchRadiusActionSheet, animated: true)
}
    
    func stringFormatter(originalString: String) -> String {
        let formattedString = originalString.replacingOccurrences(of: "_", with: " ")
        
        if formattedString == "car repair" {
            return "car repair shop"
        }
        
        if formattedString == "store" {
            return "propane service"
        }
        
        return formattedString
    }
    
    func showNoAmenitiesAlert() {
        let noAmenitiesAlert = UIAlertController(title: nil, message: "There are no \(stringFormatter(originalString: selectedType!))s within the specified radius. You can try adjusting the search radius", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        noAmenitiesAlert.addAction(okAction)
        self.present(noAmenitiesAlert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAmmenityDetail" {
            guard let detailVC = segue.destination as? AmenityDetailViewController else { return }
            
            detailVC.selectedAmmenity = selectedAmmenity
        }
    }
}

extension AmenityMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 11, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
}

extension AmenityMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let ammenityMarker = marker as? AmmenityMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("AmmenityMarkerView") as? AmmenityMarkerView else {
            return nil
        }
        
        
        guard let selectedType = selectedType,
        let usersLatitude = locationManager.location?.coordinate.latitude,
        let usersLongitude = locationManager.location?.coordinate.longitude,
        let destinationLatitude = ammenityMarker.googlePlace.geometry?.location?.lat,
        let destinationLongitude = ammenityMarker.googlePlace.geometry?.location?.lng else { return nil }
        
        infoView.ammenityNameLabel.text = ammenityMarker.googlePlace.name
        infoView.ammenityImageView.image = UIImage(named: "\(selectedType)_pin")
        
        // Calculates distance to ammenity
        var usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        if campgroundCoordinates != nil {
            let coordinates = CLLocation(latitude: campgroundCoordinates?.latitude ?? 0, longitude: campgroundCoordinates?.longitude ?? 0)
            usersLocation = coordinates
        }
        let destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        let distanceInMeters = usersLocation.distance(from: destination)
        let distanceInMiles = Double(distanceInMeters) * 0.000621371
        
        infoView.milesAwayLabel.text = "\(distanceInMiles.roundToPlaces(places: 2)) miles away"
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let ammenityMarker = marker as? AmmenityMarker else { return false }
        let selectedAmmenity = ammenityMarker.googlePlace.placeID
        self.selectedAmmenity = selectedAmmenity
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let ammenityMarker = marker as? AmmenityMarker
        performSegue(withIdentifier: "toAmmenityDetail", sender: ammenityMarker?.googlePlace)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        fetchNearbyPlaces(coordinate: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        return false
    }
}