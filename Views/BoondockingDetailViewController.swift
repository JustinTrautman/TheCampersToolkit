//
//  BoondockingDetailViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/23/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class BoondockingDetailViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var fireringLabel: UILabel!
    @IBOutlet weak var flatLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var flushTiolet: UILabel!
    @IBOutlet weak var grillLabel: UILabel!
    @IBOutlet weak var nonPortableWaterLabel: UILabel!
    @IBOutlet weak var portableWaterLabel: UILabel!
    @IBOutlet weak var picnicTableLabel: UILabel!
    @IBOutlet weak var pitToiletLabel: UILabel!
    
    // MARK: - Properties
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func directionsButtonTapped(_ sender: Any) {
    print("Directions Button Tapped")
        guard let latitude = selectedBoondock?.latitude,
            let longitude = selectedBoondock?.longitude,
        let title = selectedBoondock?.description else { return }
        
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            UIApplication.shared.canOpenURL(NSURL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")! as URL)
        } else {
            print("Opening in Apple Maps")
            
            let latAsDouble = Double("\(latitude)") ?? 0
            let lonAsDouble = Double("\(longitude)") ?? 0
            let lat = CLLocationDegrees(exactly: latAsDouble) ?? 0
            let lon = CLLocationDegrees(exactly: lonAsDouble) ?? 0
            
            let coordinates = CLLocationCoordinate2DMake(lat, lon)
            let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            mapItem.name = title
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    func setupMapView() {
        if let selectedBoondock = selectedBoondock {
            guard let latitude = selectedBoondock.latitude,
                let longitude = selectedBoondock.longitude else { return }
            
            let latitudeAsDouble = Double("\(latitude)") ?? 0
            let longitudeAsDouble = Double("\(longitude)") ?? 0
            let coordinates = CLLocationCoordinate2D(latitude: latitudeAsDouble, longitude: longitudeAsDouble)
            let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 19)
            self.mapView.camera = camera
            self.mapView.mapType = GMSMapViewType.satellite
            
            let marker = GMSMarker()
            marker.position = coordinates
            marker.title = selectedBoondock.description
            marker.map = self.mapView
        }
    }
    
    func updateViews() {
        if let description = selectedBoondock?.description {
            descriptionLabel.text = description
        }
        
        if let lastUpdated = selectedBoondock?.dateLastUpdated {
            
            if let range = lastUpdated.range(of: ":") {
                let formattedDate = lastUpdated[(lastUpdated.startIndex)..<range.lowerBound]
                lastUpdatedLabel.text = "\(formattedDate)"
            }
        }
        
        if let fireRing = selectedBoondock?.fireRing {
            fireringLabel.text = fireRing
        }
        
        if let flat = selectedBoondock?.flat {
            flatLabel.text = flat
        }
        
        if let length = selectedBoondock?.length {
            lengthLabel.text = length
        }
        
        if let flushToilet = selectedBoondock?.flushToilet {
            flushTiolet.text = flushToilet
        }
        
        if let grill = selectedBoondock?.grill {
            grillLabel.text = grill
        }
        
        if let nonPortableWater = selectedBoondock?.nonPotableWater {
            nonPortableWaterLabel.text = nonPortableWater
        }
        
        if let portableWater = selectedBoondock?.portableWater {
            portableWaterLabel.text = portableWater
        }
        
        if let picnicTable = selectedBoondock?.picnicTable {
            picnicTableLabel.text = picnicTable
        }
        
        if let pitToilet = selectedBoondock?.pitToilet {
            pitToiletLabel.text = pitToilet
        }
    }
}
