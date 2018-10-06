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
import GoogleMobileAds

class BoondockingDetailViewController: UIViewController, GMSMapViewDelegate, GADInterstitialDelegate {
    
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
    var interstitial: GADInterstitial!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        updateViews()
        setupDirectionsButton()
        
        // If user is engaged, ask for rating
        AppRatingHelper.askForRating()
        
        // Show interstitial ad on certain app launch intervals
        interstitial = createAndLoadInterstitial()
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
            lengthLabel.text = "\(length) ft."
            
            if length == "" {
                lengthLabel.text = "unknown"
            }
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
    
    func setupDirectionsButton() {
        directionsButton.layer.cornerRadius = 10.0
        directionsButton.clipsToBounds = true
        directionsButton.layer.shadowRadius = 3.0
        directionsButton.layer.shadowColor = UIColor.black.cgColor
        directionsButton.layer.shadowOpacity = 1.0
        directionsButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        directionsButton.layer.masksToBounds = false
        directionsButton.backgroundColor = UIColor(displayP3Red: 0.07, green: 0.68, blue: 0.63, alpha: 1.00)
        directionsButton.setTitle("Directions to this site", for: .normal)
        directionsButton.setTitleColor(.white, for: .normal)
        directionsButton.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial!) {
        print("Successfully loaded interstitial ad!")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial!) {
        print("I didn't receive an interstitial ad to display from the network.")
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let appLaunchCount = UserDefaults.standard.integer(forKey: "launchCount")
        
        switch appLaunchCount {
        case 12, 30, 45, 75, 100, 150, 200:
            let interstitial = GADInterstitial(adUnitID: "\(Constants.interstitialAdUnitID)")
            interstitial.delegate = self
            interstitial.load(GADRequest())
            return interstitial
        default:
            print("Did not load ad. 🔥🔥🔥App has been launched \(appLaunchCount) times🔥🔥🔥.")
            break
        }
        return GADInterstitial()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSatelliteVC" {
            guard let detailVC = segue.destination as?  SatelliteViewController else { return }
            guard let latitude = selectedBoondock?.latitude,
                let longitude = selectedBoondock?.longitude else { return }
            let latitudeAsDouble = Double("\(latitude)") ?? 0
            let longitudeAsDouble = Double("\(longitude)") ?? 0
            let coordinates = CLLocationCoordinate2D(latitude: latitudeAsDouble, longitude: longitudeAsDouble)
            detailVC.boondockCoordinates = coordinates
        }
    }
}
