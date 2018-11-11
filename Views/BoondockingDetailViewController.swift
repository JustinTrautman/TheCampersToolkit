/*
 ----------------------------------------------------------------------------------------
 
 BoondockingDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/23/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import MapKit
import GoogleMobileAds

var shownAd: Bool = false

class BoondockingDetailViewController: UIViewController, GMSMapViewDelegate, GADInterstitialDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
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
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    var interstitial: GADInterstitial!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Website and phonenumber buttons disabled unless data is available
        visitWebsiteButton.isEnabled = false
        visitWebsiteButton.setTitleColor(.gray, for: .disabled)
        phoneNumberButton.isEnabled = false
        phoneNumberButton.setTitleColor(.gray, for: .disabled)
        
        setupMapView()
        updateViews()
        setupDirectionsButton()
        
        // If user is engaged, ask for rating
        AppRatingHelper.askForRating()
        
        // Show interstitial ad one time on certain app launch intervals
        if shownAd == false {
            interstitial = createAndLoadInterstitial()
        }
        
    }
    
    // MARK: - Actions
    @IBAction func directionsButtonTapped(_ sender: Any) {
        guard let latitude = selectedBoondock?.latitude,
            let longitude = selectedBoondock?.longitude,
            let boondockTitle = selectedBoondock?.description else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
        
        OpenUrlHelper.openNavigationApp(withAddress: nil, orCoordinates: coordinates, mapItemName: boondockTitle)
        
    }
    
    @IBAction func visitWebsiteButtonTapped(_ sender: Any) {
        if let url = selectedBoondock?.website {
            OpenUrlHelper.openWebsite(with: url)
        }
    }
    
    @IBAction func PhoneNumberButtonTapped(_ sender: Any) {
        guard let numberToCall = phoneNumberButton.currentTitle?.replacingOccurrences(of: " ", with: "") else { return }

        OpenUrlHelper.call(phoneNumber: numberToCall)
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
            marker.icon = UIImage(named: "boondocking_pin")
            marker.title = selectedBoondock.description
            marker.map = self.mapView
        }
    }
    
    func updateViews() {
        if let website = selectedBoondock?.website {
            if website != "" {
            visitWebsiteButton.isEnabled = true
            visitWebsiteButton.setTitleColor(.black, for: .normal)
            }
        }
        
        if let phoneNumber = selectedBoondock?.phone {
            if phoneNumber != "" {
                let numberToDisplay = phoneNumber.replacingOccurrences(of: " ", with: "")
                phoneNumberButton.isEnabled = true
                phoneNumberButton.setTitle(numberToDisplay, for: .normal)
                phoneNumberButton.setTitleColor(.blue, for: .normal)
            }
        }
        
        if let description = selectedBoondock?.description {
            descriptionTextView.text = description
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
        directionsButton.layer.cornerRadius = 11.0
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
        case 12, 30, 45, 60, 75, 100, 125, 150, 200:
            let interstitial = GADInterstitial(adUnitID: "\(Constants.interstitialAdUnitID)")
            interstitial.delegate = self
            interstitial.load(GADRequest())
            shownAd = true
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
