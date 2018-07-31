//
//  TravelMapViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

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
   // private let searchRadius: Double = 16094
    private let searchRadius: Double = 5000
    var pointOfInterest: GooglePlace?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedType = selectedType else { return }
        
        print(selectedType)
        
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        guard let selectedType = self.selectedType else { return }
        
        dataProvider.fetchPlacesNearCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: searchRadius, types: [selectedType]) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.mapView
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
}

extension TravelMapViewController: GMSMapViewDelegate {
    
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
            infoView.placePhoto.image = UIImage(named: "\(placeMarker.place.placeType)_pin")
        }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        mapView.selectedMarker = nil
        return false
    }

}
