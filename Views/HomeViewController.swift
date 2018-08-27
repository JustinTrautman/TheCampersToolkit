/*
 ----------------------------------------------------------------------------------------
 
 HomeViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import SwiftyJSON

class HomeViewController: UIViewController, UISearchControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchThisAreaButton: UIButton!
    
    // MARK: - Properties
    private var searchedTypes = "campground"
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 50000
    
    var campground: GooglePlace?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        searchBar.delegate = self
        
    }
    
    // MARK: - Actions
    @IBAction func searchIconTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.isNavigationBarHidden = true
        searchBar.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.isNavigationBarHidden = false
        searchBar.isHidden = true
    }
    
    @IBAction func searchThisAreaButtonTapped(_ sender: Any) {
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        guard let searchText = searchBar.text,
            let location = locationManager.location?.coordinate else { return }
        
        var coordinates = GetCoordinates.getLocationFromAddress(address: searchText)
        
        
        if searchText == "" {
            coordinates = location
        }
        
        dataProvider.fetchPlacesNearCoordinate(latitude: coordinates.latitude, longitude: coordinates.longitude, radius: searchRadius, types: [searchedTypes]) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.mapView
                self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 10, bearing: 0, viewingAngle: 0)
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: Any) {
        
        guard let searchText = searchBar.text else { return }
        
        let coordinates = GetCoordinates.getLocationFromAddress(address: searchText)
        fetchNearbyPlaces(coordinate: coordinates)
        
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
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
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
}

// MARK: - GMSMapViewDelegate
extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        
        infoView.nameLabel.text = placeMarker.place.name
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "campground_pin")
        }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "campgroundDetail" {
            guard let detailVC = segue.destination as? CampgroundDetailViewController else { return }
            detailVC.campground = sender as? GooglePlace
            detailVC.campgrounds = sender as? Result
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        let campgroundMarker = marker as? PlaceMarker
        performSegue(withIdentifier: "campgroundDetail", sender: campgroundMarker?.place)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        guard let coordinate = locationManager.location?.coordinate else { return false }
        
        mapView.selectedMarker = nil
        searchBar.text = ""
        fetchNearbyPlaces(coordinate: coordinate)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("Changed Position")
        
        // TODO: Feature in V. 1.5 - Allow user to update their search based on where they scrolled to on the map.
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        self.navigationController?.isNavigationBarHidden = false
        searchBar.isHidden = true
        
        guard let searchText = searchBar.text else { return }
        
        let coordinates = GetCoordinates.getLocationFromAddress(address: searchText)
        fetchNearbyPlaces(coordinate: coordinates)
    }
}

