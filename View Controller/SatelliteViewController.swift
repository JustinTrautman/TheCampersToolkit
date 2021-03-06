/*
 ----------------------------------------------------------------------------------------
 
 SatelliteViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/27/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps

class SatelliteViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    // MARK: - Properties
    var selectedCampground: Results?
    var boondockCoordinates: CLLocationCoordinate2D?
    private var mapType: GMSMapViewType?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapType = GMSMapViewType.hybrid
        setupMapView()
    }
    
    // MARK: - Actions
    @IBAction func mapPinTapped(_ sender: Any) {
        let mapTypeActionSheet = UIAlertController(title: "Map Type", message: nil, preferredStyle: .actionSheet)
        mapTypeActionSheet.view.tintColor = .blue
        
        let normalAction = UIAlertAction(title: "Normal", style: .default) { (normal) in
            self.mapType = GMSMapViewType.normal
            self.setupMapView()
        }
        
        let hybridAction = UIAlertAction(title: "Hybrid", style: .default) { (hybrid) in
            self.mapType = GMSMapViewType.hybrid
            self.setupMapView()
        }
        
        let terrainAction = UIAlertAction(title: "Terrain", style: .default) { (terrain) in
            self.mapType = GMSMapViewType.terrain
            self.setupMapView()
        }
        
        let satelliteAction = UIAlertAction(title: "Satellite", style: .default) { (satellite) in
            self.mapType = GMSMapViewType.satellite
            self.setupMapView()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if mapType == GMSMapViewType.satellite {
            satelliteAction.isEnabled = false
        }
        
        if mapType == GMSMapViewType.normal {
            normalAction.isEnabled = false
        }
        
        if mapType == GMSMapViewType.hybrid {
            hybridAction.isEnabled = false
        }
        
        if mapType == GMSMapViewType.terrain {
            terrainAction.isEnabled = false
        }
        
        mapTypeActionSheet.addAction(normalAction)
        mapTypeActionSheet.addAction(satelliteAction)
        mapTypeActionSheet.addAction(hybridAction)
        mapTypeActionSheet.addAction(terrainAction)
        mapTypeActionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(mapTypeActionSheet, animated: true)
        }
    }
    
    func setupMapView() {
        if boondockCoordinates != nil {
            let coordinates = boondockCoordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            
            let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 17)
            self.mapView.camera = camera
            self.mapView.mapType = mapType ?? GMSMapViewType.satellite
            
            let marker = GMSMarker()
            marker.position = coordinates
            marker.title = "Boondock"
            marker.icon = UIImage(named: "campground_pin")
            marker.map = self.mapView
        }
        
        guard let selectedCampground = selectedCampground else { return }
        
        navigationBar.title = selectedCampground.name
        
        let latitude = selectedCampground.geometry?.location?.lat ?? 0
        let longitude = selectedCampground.geometry?.location?.lng ?? 0
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 17)
        self.mapView.camera = camera
        self.mapView.mapType = mapType ?? GMSMapViewType.satellite
        
        let marker = GMSMarker()
        marker.position = coordinates
        marker.title = selectedCampground.name
        marker.icon = UIImage(named: "campground_pin")
        marker.map = self.mapView
    }
}
