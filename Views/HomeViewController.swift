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
import Lottie
import Kingfisher

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var navigationBar: UINavigationItem!
    @IBOutlet weak private var searchButton: UIBarButtonItem!
    @IBOutlet weak private var mapView: GMSMapView!
    @IBOutlet private var noLocationView: NoLocationView!
    
    // MARK: - Actions
    @IBAction func searchIconTapped(_ sender: UIBarButtonItem) {
        openSearchWindow()
    }
    
    // MARK: - Properties
    private var searchType = "campground"
    private var shownNoLocationView = false
    private let locationManager = CLLocationManager()
    private let searchRadius: Double = 50000 // <<< 31 miles. Max allowed by Google.
    private let placesClient = GMSPlacesClient()
    private let geoCoder = CLGeocoder()
    
    var campgroundDetails: Result?
    var googlePlaces: [Results]? // All campgrounds
    var selectedCampground: Results? // Selected campground passed to detailVC
    
    // Layout Properties
    let loadingOverlay: UIView = {
        let loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = .clear
        return loadingView
    }()
    
    let loadingAnimation: LOTAnimationView = {
        let animation = LOTAnimationView(name: "mapLoading")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.layer.masksToBounds = true
        return animation
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Fetcher Functions
    func fetchCampgroundsAround(coordinates: CLLocationCoordinate2D?) {
        guard let location = locationManager.location?.coordinate else {
            return
        }
        resetMapView()
        
        let latitude = coordinates?.latitude ?? location.latitude
        let longitude = coordinates?.longitude ?? location.longitude
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.disableInterfaceInteraction()
            self.showLoadingOverlay()
            self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoom: 10, bearing: 0, viewingAngle: 0)
        }
        
        GooglePlaceSearchController.fetchPlacesNearby(latitude: String(latitude), longitude: String(longitude), radius: self.searchRadius, type: self.searchType, completion: { (places) in
            if let places = places {
                DispatchQueue.main.async {
                    places.forEach {
                        let marker = CampgroundMarker(place: $0)
                        marker.map = self.mapView
                    }
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.loadingOverlay.removeFromSuperview()
                self.mapView.alpha = 1.0
                self.enableInterfaceInteraction()
            }
            
            if places?.count == 0 {
                AlertHelper.showNoCampgroundsAlert(on: self)
            }
        })
    }
    
    func fetchCampgroundDetails() {
        guard let selectedCampground = selectedCampground else { return }
        let placeID = selectedCampground.placeID ?? ""
        GoogleDetailController.fetchPlaceDetailsWith(placeId: placeID) { (details) in
            if let campgroundDetails = details {
                self.campgroundDetails = campgroundDetails
            }
        }
    }
    
    func openSearchWindow() {
        let searchWindow = UIAlertController(title: nil, message: "Enter any location to find nearby campgrounds", preferredStyle: .alert)
        
        var searchTextField: UITextField?
        
        searchWindow.addTextField { (textField) in
            searchTextField?.placeholder = "City or Attraction"
            searchTextField = textField
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { (search) in
            guard let searchText = searchTextField?.text?.capitalized, !searchText.isEmpty else { return }
            self.resetMapView()
            self.navigationBar.title = searchText
            
            // TODO: Move to extension
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchText, completionHandler: { (placemarks, error) in
                if let _ = error {
                    AlertHelper.showCustomAlert(on: self, title: "No Search Results", message: "We couldn't find any results for '\(searchText)'. Please check spelling and try again.")
                    return
                }
                
                guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
                
                let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                self.fetchCampgroundsAround(coordinates: coordinates)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        searchWindow.addAction(searchAction)
        searchWindow.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(searchWindow, animated: true)
        }
    }
    
    func resetMapView() {
        DispatchQueue.main.async {
            self.mapView.selectedMarker = nil
            self.mapView.clear()
        }
    }
    
    func showLoadingOverlay() {
        self.mapView.addSubview(loadingOverlay)
        self.mapView.bringSubviewToFront(loadingOverlay)
        
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        loadingOverlay.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        loadingOverlay.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1/2).isActive = true
        loadingOverlay.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1/3).isActive = true
        
        loadingOverlay.addSubview(loadingAnimation)
        loadingAnimation.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimation.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor).isActive = true
        loadingAnimation.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor).isActive = true
        loadingAnimation.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loadingAnimation.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        DispatchQueue.main.async {
            self.mapView.alpha = 0.8
            self.loadingAnimation.play()
            self.loadingAnimation.loopAnimation = true
        }
    }
    
    func showNoLocationAccessWindow() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.isUserInteractionEnabled = false
        
        mapView.addSubview(noLocationView)
        mapView.bringSubviewToFront(noLocationView)
        
        noLocationView.translatesAutoresizingMaskIntoConstraints = false
        noLocationView.isOpaque = true
        noLocationView.alpha = 1.0
        
        noLocationView.centerXAnchor.constraint(equalTo: self.mapView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noLocationView.centerYAnchor.constraint(equalTo: self.mapView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noLocationView.widthAnchor.constraint(equalTo: self.mapView.safeAreaLayoutGuide.widthAnchor, constant: -90).isActive = true
        noLocationView.heightAnchor.constraint(equalTo: self.mapView.heightAnchor, multiplier: 1/2).isActive = true
        
        shownNoLocationView = true
    }
    
    func enableInterfaceInteraction() {
        DispatchQueue.main.async {
            self.searchButton.isEnabled = true
            self.mapView.isUserInteractionEnabled = true
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
    }
    
    func disableInterfaceInteraction() {
        DispatchQueue.main.async {
            self.searchButton.isEnabled = false
            self.mapView.isUserInteractionEnabled = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CampgroundDetailViewController.segueIdentifier {
            guard let detailVC = segue.destination as? CampgroundDetailViewController else { return }
            detailVC.campgroundDetails = campgroundDetails
            detailVC.selectedCampground = selectedCampground
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .denied else {
            showNoLocationAccessWindow()
            return
        }
        
        if shownNoLocationView {
            noLocationView.removeFromSuperview()
            enableInterfaceInteraction()
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        fetchCampgroundsAround(coordinates: location.coordinate)
        locationManager.stopUpdatingLocation()
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
        infoView.placePhoto.image = UIImage(named: "blackMoreArrow")
        
        // Calculate distance to amenity
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
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.navigationController?.isNavigationBarHidden = false
        let campgroundMarker = marker as? CampgroundMarker
        performSegue(withIdentifier: CampgroundDetailViewController.segueIdentifier, sender: campgroundMarker?.place)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let coordinate = locationManager.location?.coordinate else { return false }
        
        navigationBar.title = "Campgrounds Near You"
        fetchCampgroundsAround(coordinates: coordinate)
        
        return false
    }
}
