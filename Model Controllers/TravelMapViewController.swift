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

class TravelMapViewController: UIViewController {
    
    static let shared = TravelMapViewController()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properties
    var selectedType: String?
    private var locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 8047 // Searches with 5 mile radius.
    
    var pointOfInterest: Result?
    var results: [Results]?
    var ammenityImage: UIImage?
    var placeID: String?
    var placePhotoReference: String?
    var selectedAmmenity: String?
    
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
        
        GooglePlaceSearchController.fetchPlacesNearby(latitude: "\(coordinate.latitude)", longitude: "\(coordinate.longitude)", radius: searchRadius, type: selectedType) { (places) in
            
            if let places = places {
                DispatchQueue.main.async {
                    for place in places {
                        let marker = AmmenityMarker(googlePlace: place)
                        self.placeID = marker.googlePlace.placeID
                        marker.map = self.mapView
                        self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
                        self.results = places
                    }
                }
                
                if places.count == 0 {
                    self.showNoAmenitiesAlert()
                }
            }
        }
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
        let noAmenitiesAlert = UIAlertController(title: nil, message: "There are no \(stringFormatter(originalString: selectedType!))s within 5 miles of you", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        noAmenitiesAlert.addAction(okAction)
        self.present(noAmenitiesAlert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAmmenityDetail" {
            guard let detailVC = segue.destination as? AmmenityDetailViewController else { return }
            
            detailVC.selectedAmmenity = selectedAmmenity
//            detailVC.ammenityImage = ammenityImage
        }
    }
}

extension TravelMapViewController: CLLocationManagerDelegate {
    
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

extension TravelMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let ammenityMarker = marker as? AmmenityMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("AmmenityMarkerView") as? AmmenityMarkerView else {
            return nil
        }
        
        infoView.ammenityNameLabel.text = ammenityMarker.googlePlace.name
        
        if let price = pointOfInterest?.priceLevel {
            if price <= 1 {
                infoView.priceLevelLabel.text = "$"
            }
            
            if price == 2 {
                infoView.priceLevelLabel.text = "$$"
            }
            
            if price > 2 {
                infoView.priceLevelLabel.text = "$$$"
            }
        }
        
        if let openNow = pointOfInterest?.openingHours?.openNow {
            print(openNow)
            if openNow == true {
                infoView.isOpenLabel.text = "Open now"
            } else {
                infoView.isOpenLabel.text = "Closed now"
            }
        }
        
        // TODO: - Remove image code
//        if let photo = ammenityImage {
//            DispatchQueue.main.async {
//                infoView.ammenityImageView.image = photo
//            }
        
//        } else {
            guard let selectedType = selectedType else { return nil }
            infoView.ammenityImageView.image = UIImage(named: "\(selectedType)_pin")
//        }
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
