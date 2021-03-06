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
import Lottie
import SafariServices

class BoondockingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var mapView: GMSMapView!
    @IBOutlet weak private var navigationBar: UINavigationItem!
    @IBOutlet weak private var searchButton: UIBarButtonItem!
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        openSearchWindow()
    }
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    private var boondockingLocations: [Boondocking]?
    private var selectedBoondock: Boondocking?
    private var agreedToToU = UserDefaults.standard.bool(forKey: "Alerted")
    
    // Layout Properties
    private let loadingOverlay: UIView = {
        let loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = .clear
        return loadingView
    }()
    
    private let loadingAnimation: LOTAnimationView = {
        let animation = LOTAnimationView(name: "mapLoading")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.layer.masksToBounds = true
        return animation
    }()
    
    // MARK: - View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        listenForAgreement()
        
        if !agreedToToU {
            AlertHelper.showAgreementAlert(on: self) // User must agree to Terms of Use before using.
        } else {
            fetchBoondockingLocations()
        }
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
            self.navigationBar.title = searchText.capitalized
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
                if let _ = error {
                    AlertHelper.showCustomAlert(on: self, title: "No Search Results", message: "We couldn't find any results for '\(searchText)'. Please check spelling and try again.")
                    return
                }
                
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
        
        DispatchQueue.main.async {
            self.present(searchWindow, animated: true)
        }
    }
    
    func fetchBoondockingLocations() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.disableInterfaceInteraction()
            self.showLoadingOverlay()
        }
        
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
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.loadingOverlay.removeFromSuperview()
                    self.mapView.alpha = 1.0
                    self.enableInterfaceInteraction()
                }
            }
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
    
    func enableInterfaceInteraction() {
        navigationController?.navigationBar.isUserInteractionEnabled = true
        mapView.isUserInteractionEnabled = true
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func disableInterfaceInteraction() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        mapView.isUserInteractionEnabled = false
        tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    func listenForAgreement() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleToUAgreement), name: Constants.agreeKey, object: nil)
    }
    
    @objc func handleToUAgreement() {
        // If user has agreed, fetch boondocking locations and never ask again.
        fetchBoondockingLocations()
    }
    
    // MARK: - Navigation
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: BoondockDetailViewController.segueIdentifier, sender: BoondockingMarker.self)
    }
}

extension BoondockingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
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
        if segue.identifier == BoondockDetailViewController.segueIdentifier {
            guard let detailVC = segue.destination as? BoondockDetailViewController else { return }
            
            detailVC.boondockingLocations = boondockingLocations
            detailVC.selectedBoondock = selectedBoondock
        }
    }
}

extension BoondockingViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            AlertHelper.showAgreementAlert(on: self)
        }
    }
}

