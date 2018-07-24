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
    
    // MARK: - Properties
    private var searchedTypes = ["campground"]
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 321869
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
        searchBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    public func getLocationFromAddress(address : String) -> CLLocationCoordinate2D {
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        do {
            
            let url = String(format: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=%@&key=\(Constants.googleApiKey)", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
            let result = try Data(contentsOf: URL(string: url)!)
            let json = try JSON(data: result)
            
            lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
            lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
            
            print(lat)
            print(lon)
            
        }
        catch let error{
            print(error)
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        guard let searchText = searchBar.text,
            let location = locationManager.location?.coordinate else { return }
        
        var coordinates = getLocationFromAddress(address: searchText)
        
        if searchText == "" {
            coordinates = location
        }
        
        dataProvider.fetchPlacesNearCoordinate(latitude: coordinates.latitude, longitude: coordinates.longitude, radius: searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.mapView
                self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 10, bearing: 0, viewingAngle: 0)
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: Any) {
        
        guard let searchText = searchBar.text else { return }
        
        let coordinates = getLocationFromAddress(address: searchText)
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
    
    //    // when user tap the info window of store marker, pass selected store to the product list controller
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        let controller = segue.destinationViewController as ProductMenuController
    //        controller.store = sender as Store
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "campgroundDetail" {
            guard let detailVC = segue.destination as? CampgroundDetailViewController else { return }
            detailVC.campground = sender as? GooglePlace
            detailVC.campgrounds = sender as? Result
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        print("Did tap")
        
        let campgroundMarker = marker as? PlaceMarker
        performSegue(withIdentifier: "campgroundDetail", sender: campgroundMarker?.place)
        
        print(campgroundMarker?.place.name)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        guard let coordinate = locationManager.location?.coordinate else { return false }
        
        mapView.selectedMarker = nil
        searchBar.text = ""
        fetchNearbyPlaces(coordinate: coordinate)
        return false
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        
        guard let searchText = searchBar.text else { return }
        
        let coordinates = getLocationFromAddress(address: searchText)
        fetchNearbyPlaces(coordinate: coordinates)
    }
}

