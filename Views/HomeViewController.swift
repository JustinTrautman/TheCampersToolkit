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

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    private var searchedTypes = "campground"
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 50000 // <<< 31 Miles. Max allowed by Google.
    private let placesClient = GMSPlacesClient()
    var fetcher: GMSAutocompleteFetcher?
    
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
        navigationController?.isNavigationBarHidden = true
        searchBar.isHidden = false
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        guard var searchText = searchBar.text,
            let location = locationManager.location?.coordinate else { return }
        
        if searchText == "" {
            searchText = "\(location.latitude) \(location.longitude)"
        }
        
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
        guard let infoView = UIView.viewFromNibName("CampgroundMarkerView") as? CampgroundMarkerView,
            let usersLatitude = locationManager.location?.coordinate.latitude,
            let usersLongitude = locationManager.location?.coordinate.longitude else { return nil }
        
        let destinationLatitude = placeMarker.place.coordinate.latitude
        let destinationLongitude = placeMarker.place.coordinate.longitude
        
        infoView.nameLabel.text = placeMarker.place.name
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "campground_pin")
        }
        
        // Calculates distance to ammenity
        let usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        let destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        let distanceInMeters = usersLocation.distance(from: destination)
        let distanceInMiles = Double(distanceInMeters) * 0.000621371
        infoView.milesAwayLabel.text = "\(distanceInMiles.roundToPlaces(places: 2)) miles away"
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
    
    func placeAutoComplete() {
        guard let searchText = searchBar.text else { return }
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (results, error) in
            if let error = error {
                print("Autocomplete error \(error); \(error.localizedDescription)")
            }
            
            if let results = results {
                for result in results {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        }
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
        
        navigationItem.title = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.isNavigationBarHidden = false
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
    }
}
