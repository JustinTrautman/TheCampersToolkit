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
    private let searchRadius: Double = 10000 // <<< 31 miles. Max allowed by Google.
    private let placesClient = GMSPlacesClient()
    let geoCoder = CLGeocoder()
    
    var fetcher: GMSAutocompleteFetcher?
    var campgroundDetails: Result?
    var googlePlaces: [Results]? // All campgrounds
    var selectedCampground: Results? // Selected campground passed to detailVC
    var campgroundPhoto: UIImage?
    
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
    
    func fetchCampgroundsAround(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        guard var searchText = searchBar.text,
            let location = locationManager.location?.coordinate else { return }
        
        if searchText == "" {
            searchText = "\(location.latitude) \(location.longitude)"
        }
        
        geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            var coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            if searchText == "" {
                coordinates = location
            }
            
            GooglePlaceSearchController.fetchPlacesNearby(latitude: "\(coordinates.latitude)", longitude: "\(coordinates.longitude)", radius: self.searchRadius, type: self.searchedTypes, completion: { (places) in
                if let places = places {
                    DispatchQueue.main.async {
                        places.forEach {
                            let marker = CampgroundMarker(place: $0)
                            marker.map = self.mapView
                            self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 10, bearing: 0, viewingAngle: 0)
                        }
                        
                    }
                }
                if places?.count == 0 {
                    self.showNoCampgroundsAlert()
                }
            })
        }
    }
    
    func fetchCampgroundDetails() {
        guard let selectedCampground = selectedCampground else { return }
        let placeID = selectedCampground.placeID ?? ""
        GoogleDetailController.fetchPlaceDetailsWith(placeId: placeID) { (details) in
            if let details = details {
                self.campgroundDetails = details
            }
            self.fetchCampgroundPhoto()
        }
    }
    
    func fetchCampgroundPhoto() {
        guard let campgroundDetails = campgroundDetails,
            let photosArray = campgroundDetails.photos,
            let photoReference = photosArray[0].photoReference else { return }
        
        GoogleDetailController.fetchCampgroundPhotosWith(photoReference: photoReference) { (photo) in
            if let photo = photo {
                self.campgroundPhoto = photo
            }
        }
    }
    
    func showNoCampgroundsAlert() {
        let noCampgroundsAlert = UIAlertController(title: nil, message: "There are no campgrounds within 31 miles. Try searching another area.", preferredStyle: .alert)
        noCampgroundsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(noCampgroundsAlert, animated: true)
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
        fetchCampgroundsAround(coordinate: location.coordinate)
    }
}

// MARK: - GMSMapViewDelegate
extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let campgroundMarker = marker as? CampgroundMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("CampgroundMarkerView") as? CampgroundMarkerView,
            let usersLatitude = locationManager.location?.coordinate.latitude,
            let usersLongitude = locationManager.location?.coordinate.longitude else { return nil }
        
        let destinationLatitude = campgroundMarker.place.geometry?.location?.lat ?? 0
        let destinationLongitude = campgroundMarker.place.geometry?.location?.lng ?? 0
        
        // Fetch campground details and photo and pass to detailVC
        fetchCampgroundDetails()
        
        infoView.nameLabel.text = campgroundMarker.place.name
        infoView.placePhoto.image = UIImage(named: "campground_pin")
        
        // Calculates distance to amenity
        let usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        let destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        let distanceInMeters = usersLocation.distance(from: destination)
        let distanceInMiles = Double(distanceInMeters) * 0.000621371
        infoView.milesAwayLabel.text = "\(distanceInMiles.roundToPlaces(places: 2)) miles away"
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Make the selected Google Map marker the selected campground and pass to detailVC
        guard let campgroundMarker = marker as? CampgroundMarker else { return false }
        selectedCampground = campgroundMarker.place
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "campgroundDetail" {
            guard let detailVC = segue.destination as? CampgroundDetailViewController else { return }
            detailVC.campgroundDetails = campgroundDetails
            detailVC.selectedCampground = selectedCampground
            detailVC.campgroundPhoto = campgroundPhoto
            
            campgroundPhoto = nil // Reset to no photo after it has been passed to detailVC
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.navigationController?.isNavigationBarHidden = false
        
        let campgroundMarker = marker as? CampgroundMarker
        performSegue(withIdentifier: "campgroundDetail", sender: campgroundMarker?.place)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let coordinate = locationManager.location?.coordinate else { return false }
        
        mapView.selectedMarker = nil
        searchBar.text = ""
        fetchCampgroundsAround(coordinate: coordinate)
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("Changed Position")
        // TODO: Allow user to update their search based on where they scrolled to on the map (Depends on Api traffic).
    }
    
    func placeAutoComplete() {
        guard let searchText = searchBar.text else { return }
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (results, error) in
            if let error = error {
                print("Autocomplete error \(error); \(error.localizedDescription)")
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
        
        geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
            
            let latitude = location.latitude
            let longitude = location.longitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            self.fetchCampgroundsAround(coordinate: coordinates)
            self.navigationItem.title = searchText
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.isNavigationBarHidden = false
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
    }
}
