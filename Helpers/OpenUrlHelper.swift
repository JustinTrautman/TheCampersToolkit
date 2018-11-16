//
//  OpenUrlHelper.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 10/25/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation
import MapKit
import SafariServices

var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
var markerName: String = ""

struct OpenUrlHelper {
    
    static func openWebsite(with url: String, on vc: UIViewController) {
        if let url = URL(string: url) {
            let safariVC = SFSafariViewController(url: url)
            
            DispatchQueue.main.async {
                vc.present(safariVC, animated: true)
            }
        }
    }
    
    static func call(phoneNumber: String) {
        if let phoneUrl = URL(string: "telprompt://\(phoneNumber)") {
            UIApplication.shared.canOpenURL(phoneUrl)
            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        }
    }
    
    static func openNavigationApp(withAddress: String?, orCoordinates: CLLocationCoordinate2D?, mapItemName: String) {
        
        if let addressString = withAddress {
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(addressString) { (placemarks, error) in
                if let error = error {
                    print("CLGeocoder had a problem converting \(addressString) into coordinates. The error is: \(error); \(error.localizedDescription)")
                }
                
                guard let placemarks = placemarks else { return }
                
                if let coordinatesFromAddress = placemarks.first?.location?.coordinate {
                    coordinates = CLLocationCoordinate2D(latitude: coordinatesFromAddress.latitude, longitude: coordinatesFromAddress.longitude)
                    
                    markerName = mapItemName
                    openInMaps()
                }
            }
        }
        
        if let parameterCoordinates = orCoordinates {
            coordinates = CLLocationCoordinate2D(latitude: parameterCoordinates.latitude, longitude: parameterCoordinates.longitude)
            
            markerName = mapItemName
            openInMaps()
        }
    }
    
    static func openInMaps() {
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            let url = URL(string: "comgooglemaps://?daddr=\(coordinates.latitude),\(coordinates.longitude)&directionsmode=driving")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Opening in Apple Maps")
            
            let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            mapItem.name = markerName
            mapItem.openInMaps(launchOptions: options)
        }
    }
}
