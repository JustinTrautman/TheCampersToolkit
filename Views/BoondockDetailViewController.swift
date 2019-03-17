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

class BoondockDetailViewController: UIViewController, GMSMapViewDelegate, GADInterstitialDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak private var mapView: GMSMapView!
    @IBOutlet weak private var visitWebsiteButton: UIButton!
    @IBOutlet weak private var phoneNumberButton: UIButton!
    @IBOutlet weak private var directionsButton: UIButton!
    @IBOutlet weak private var lastUpdatedLabel: UILabel!
    @IBOutlet weak private var fireringLabel: UILabel!
    @IBOutlet weak private var flatLabel: UILabel!
    @IBOutlet weak private var lengthLabel: UILabel!
    @IBOutlet weak private var flushToiletLabel: UILabel!
    @IBOutlet weak private var grillLabel: UILabel!
    @IBOutlet weak private var nonPotableWaterLabel: UILabel!
    @IBOutlet weak private var potableWaterLabel: UILabel!
    @IBOutlet weak private var picnicTableLabel: UILabel!
    @IBOutlet weak private var pitToiletLabel: UILabel!
    @IBOutlet weak private var descriptionTextView: UITextView!
    @IBOutlet weak private var descriptionTextViewHeight: NSLayoutConstraint!
    
    // MARK: - Actions
    @IBAction func directionsButtonTapped(_ sender: Any) {
        guard let latitude = selectedBoondock?.latitude,
            let longitude = selectedBoondock?.longitude,
            let boondockTitle = selectedBoondock?.description else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        OpenUrlHelper.openNavigationApp(withAddress: nil, orCoordinates: coordinates, mapItemName: boondockTitle)
    }
    
    @IBAction func visitWebsiteButtonTapped(_ sender: Any) {
        if let url = selectedBoondock?.website {
            OpenUrlHelper.openWebsite(with: url, on: self)
        }
    }
    
    @IBAction func PhoneNumberButtonTapped(_ sender: Any) {
        guard let numberToCall = phoneNumberButton.currentTitle?.replacingOccurrences(of: " ", with: "") else { return }
        OpenUrlHelper.call(phoneNumber: numberToCall)
    }
    
    // MARK: - Properties
    var boondockingLocations: [Boondocking]?
    var selectedBoondock: Boondocking?
    private var interstitial: GADInterstitial!
    
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
        directionsButton.applyGreenTheme(buttonTitle: "Directions to this site")
        
        // If user is engaged, ask for rating
        AppRatingHelper.askForRating()
        
        // Show interstitial ad one time on certain app launch intervals
        if shownAd == false {
            interstitial = createAndLoadInterstitial()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
            self.descriptionTextViewHeight.constant = self.descriptionTextView.contentSize.height
        }
    }
    
    func setupMapView() {
        if let selectedBoondock = selectedBoondock {
            guard let latitude = selectedBoondock.latitude,
                let longitude = selectedBoondock.longitude else { return }
            
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            DispatchQueue.main.async {
                let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 19)
                let marker = GMSMarker()
                
                self.mapView.camera = camera
                self.mapView.mapType = GMSMapViewType.satellite
                
                marker.position = coordinates
                marker.icon = UIImage(named: "boondocking_pin")
                marker.title = selectedBoondock.description
                marker.map = self.mapView
            }
        }
    }
    
    func updateViews() {
        let website = selectedBoondock?.website ?? "No website"
        let phone = selectedBoondock?.phone ?? "No phone number"
        let dateLastUpdated = selectedBoondock?.dateLastUpdated?.formatIsoDate ?? "unknown"
        let fireRing = selectedBoondock?.fireRing
        let flat = selectedBoondock?.flat
        let lengthValue = selectedBoondock?.length ?? 0
        let lengthInFeet = lengthValue == 0 ? "unknown" : "\(lengthValue.dropZero()) ft."
        let flushToilet = selectedBoondock?.flushToilet
        let grill = selectedBoondock?.grill
        let nonPotableWater = selectedBoondock?.nonPotableWater
        let potableWater = selectedBoondock?.potableWater
        let picnicTable = selectedBoondock?.picnicTable
        let pitToilet = selectedBoondock?.pitToilet
        let description = selectedBoondock?.description ?? "No description available"
        
        DispatchQueue.main.async {
            switch phone {
            case "No phone number", "":
                break
            default:
                self.phoneNumberButton.isEnabled = true
                self.phoneNumberButton.setTitle(phone, for: .normal)
                self.phoneNumberButton.setTitleColor(.blue, for: .normal)
            }
            
            switch website {
            case "No website", "":
                break
            default:
                self.visitWebsiteButton.isEnabled = true
                self.visitWebsiteButton.setTitleColor(.black, for: .normal)
            }
            
            self.lastUpdatedLabel.text = dateLastUpdated
            self.fireringLabel.text = fireRing?.amenityStatus()
            self.flatLabel.text = flat?.amenityStatus()
            self.lengthLabel.text = lengthInFeet
            self.flushToiletLabel.text = flushToilet?.amenityStatus()
            self.grillLabel.text = grill?.amenityStatus()
            self.nonPotableWaterLabel.text = nonPotableWater?.amenityStatus()
            self.potableWaterLabel.text = potableWater?.amenityStatus()
            self.picnicTableLabel.text = picnicTable?.amenityStatus()
            self.pitToiletLabel.text = pitToilet?.amenityStatus()
            self.descriptionTextView.text = description
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
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
            break
        }
        return GADInterstitial(adUnitID: Constants.interstitialAdUnitID)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SatelliteViewController.segueIdentifier {
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
