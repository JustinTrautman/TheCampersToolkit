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
import WebKit
import GoogleMaps
import GoogleUtilities

class BoondockingViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    let isClustering: Bool = true
    let isCustom: Bool = true
    
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    var beenAlerted = UserDefaults.standard.bool(forKey: "Alerted")
    var clusterManager: GMUClusterManager!
    
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
        
        // Marker Cluster
        let coordinates = CLLocationCoordinate2D(latitude: 39.828175, longitude: -98.5795)
        
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 14)
        mapView.camera = camera
        mapView.mapType = GMSMapViewType.normal
        
        if isClustering {
            var iconGenerator = GMUDefaultClusterIconGenerator()
            if isCustom {
            var images : [UIImage] = [UIImage(named: "m1")!, UIImage(named: "m2")!, UIImage(named: "m3")!, UIImage(named: "m4")!, UIImage(named: "m5")!]
//                images.append(UIImage(named: "gas_station_pin") ?? UIImage())
            
            iconGenerator = GMUDefaultClusterIconGenerator(buckets: [2, 10, 25, 50, 100], backgroundImages: images)
            } else {
                iconGenerator = GMUDefaultClusterIconGenerator()
            }
            
            let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
            let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
            
            clusterManager = GMUClusterManager (map: mapView, algorithm: algorithm, renderer: renderer)
 
        } else {
        }
        
        let firstLocation = CLLocationCoordinate2DMake(48.898902, -117.987654)
        let marker = GMSMarker(position: firstLocation)
        marker.icon = UIImage(named: "gas_station_pin") //Apply custom marker
        marker.map = mapView
        
        
        let secondLocation = CLLocationCoordinate2DMake(48.924572, -117.987654)
        let secondMarker = GMSMarker(position: secondLocation)
        secondMarker.icon = UIImage(named: "gas_station_pin")
        secondMarker.map = mapView
        
        let threeLocation = CLLocationCoordinate2DMake(48.841619, -117.987654)
        let threeMarker = GMSMarker(position: threeLocation)
        threeMarker.icon = UIImage(named: "gas_station_pin")
        threeMarker.map = mapView
        
        let fourLocation = CLLocationCoordinate2DMake(48.858575, -117.987654)
        let fourMarker = GMSMarker(position: fourLocation)
        fourMarker.icon = UIImage(named: "gas_station_pin")
        fourMarker.map = mapView
        
        let fiveLocation = CLLocationCoordinate2DMake(48.873819, -117.987654)
        let fiveMarker = GMSMarker(position: fiveLocation)
        fiveMarker.icon = UIImage(named: "gas_station_pin")
        fiveMarker.map = mapView
    }
    
    func addMarkers(cameraLatitude : Double, cameraLongitude : Double) {
        let clusterItemCount = 390
        let extent = 0.01
        for index in 1...clusterItemCount {
            let lat = cameraLatitude + extent * randomScale()
            let lng = cameraLongitude + extent * randomScale()
            let name = "Item \(index)"
            
            let position = CLLocationCoordinate2DMake(lat, lng)
            
            let item = POIItem(position: position, name: name)
            clusterManager.add(item)
            
        }
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func renderer (_ renderer: GMUClusterRenderer, markFor object: Any) -> GMSMarker? {
        
        let marker = GMSMarker()
        if let model = object as? BoondockingViewController {
            // set image view for gmsmarker
        }
        return marker
    }
    
    class POIItem: NSObject, GMUClusterItem {
        var position: CLLocationCoordinate2D
        var name: String!
        
        init(position: CLLocationCoordinate2D, name: String) {
            self.position = position
            self.name = name
        }
    }
    
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        let item = POIItem(position: coordinate, name: "New")
//        clusterManager.add(item)
//        clusterManager.cluster()
//    }
//
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            print("Did tap marker for cluster item \(poiItem.name)")
        } else {
            print("Did tap a normal marker")
        }
        return false
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        openSearchWindow()
        fetchBoondockingLocations()
        
    }
    
    /// Randomly generates cluster items within some extent of the camera and
    /// adds them to the cluster manager.
        
        /// Returns a random value between -1.0 and 1.0.
        private func randomScale() -> Double {
            return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
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
            
            // Search()
            print("I am now searching for dump stations in \(searchText)")
            
            // TODO: - Convert search text to coordinates
        }
        
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    searchWindow.addAction(cancelAction)
    searchWindow.addAction(searchAction)
    
    self.present(searchWindow, animated: true)
    }
    
    func fetchBoondockingLocations() {
        BoondockingController.fetchAllBoondockingLocations { (boondocking) in
            if let boondocking = boondocking {
                let coordinates = CLLocationCoordinate2D(latitude: 39.828175, longitude: -98.5795)
                self.boondockingLocations = boondocking
                
                DispatchQueue.main.async {
                    for boondocks in boondocking {
                        let marker = BoondockingMarker(boondocking: [boondocks])
                        marker.map = self.mapView

                        self.mapView.camera = GMSCameraPosition(target: coordinates, zoom: 3, bearing: 0, viewingAngle: 0)
                        let latitude = boondocks.latitude
                        let longitude = boondocks.longitude
                        let latAsDouble = Double("\(latitude)") ?? 0
                        let lonAsDouble = Double("\(longitude)") ?? 0
                    }
                }
                DispatchQueue.main.async {
                    self.clusterManager.cluster()
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
//        fetchBoondockingLocations()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? BoondockingMarker else { return nil }
        
        guard let infoView = UIView.viewFromNibName("BoondockingMarkerView") as? BoondockingMarkerView else {
            return nil
        }
        
        for boondock in placeMarker.boondocking {
            infoView.descriptionLabel.text = boondock.description
            
            guard let latitude = boondock.latitude,
                let longitude = boondock.longitude else { return  UIView() }
            
            let latitudeInDouble = Double("\(latitude)") ?? 0
            let longitudeInDouble = Double("\(longitude)") ?? 0
            print(latitudeInDouble)
            print(longitudeInDouble)
            
//            let coordinates = CLLocationCoordinate2D(latitude: latitudeInDouble, longitude: longitudeInDouble)
            
            selectedBoondock = boondock
            
//            let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 14)
//            infoView.boondockingMapView.camera = camera
//            infoView.boondockingMapView.mapType = GMSMapViewType.satellite
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
        
        let boondockMarker = marker as? BoondockingMarker
        performSegue(withIdentifier: "toBoondockDetail", sender: BoondockingMarker.self)
    }
}
