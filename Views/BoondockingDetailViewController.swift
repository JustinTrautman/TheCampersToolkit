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
    @IBOutlet weak var descriptionTableView: UITableView!
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
        descriptionTableView.delegate = self
        descriptionTableView.dataSource = self
        descriptionTableView.tableFooterView = UIView()
        
        setupMapView()
        updateViews()
        setupDirectionsButton()
        
        // If user is engaged, ask for rating
        AppRatingHelper.askForRating()
        
        // Show interstitial ad one time on certain app launch intervals
        if shownAd == false {
            interstitial = createAndLoadInterstitial()
        }
        
        // Website and phonenumber buttons disabled unless data is available
        visitWebsiteButton.isEnabled = false
        visitWebsiteButton.setTitleColor(.gray, for: .disabled)
        phoneNumberButton.isEnabled = false
        phoneNumberButton.setTitleColor(.gray, for: .disabled)
    }
    
    // MARK: - Actions
    @IBAction func directionsButtonTapped(_ sender: Any) {
        print("Directions Button Tapped")
        guard let latitude = selectedBoondock?.latitude,
            let longitude = selectedBoondock?.longitude,
            let title = selectedBoondock?.description else { return }
        
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            let url = URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    @IBAction func visitWebsiteButtonTapped(_ sender: Any) {
        if let website = selectedBoondock?.website {
            openWebsiteUrl(url: website)
        }
    }
    
    @IBAction func PhoneNumberButtonTapped(_ sender: Any) {
        guard let numberToCall = phoneNumberButton.currentTitle?.replacingOccurrences(of: " ", with: "") else { return }
        if let phoneURL = URL(string: "telprompt://\(numberToCall)") {
            UIApplication.shared.canOpenURL(phoneURL)
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
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
            marker.icon = UIImage(named: "boondocking_pin")
            marker.title = selectedBoondock.description
            marker.map = self.mapView
        }
    }
    
    func updateViews() {
        if let website = selectedBoondock?.website {
            visitWebsiteButton.isEnabled = true
            visitWebsiteButton.setTitleColor(.blue, for: .normal)
        }
        
        if let phoneNumber = selectedBoondock?.phone {
            if phoneNumber != "" {
                phoneNumberButton.isEnabled = true
                phoneNumberButton.setTitle(phoneNumber, for: .normal)
                phoneNumberButton.setTitleColor(.blue, for: .normal)
            }
        }
        
        if let _ = selectedBoondock?.description {
            self.descriptionTableView.reloadData()
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
    
    func openWebsiteUrl(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
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

extension BoondockingDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = descriptionTableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? BoondockDescriptionTableViewCell else { return UITableViewCell() }
        
        if let description = selectedBoondock?.description {
            cell.descriptionLabel.text = description
        }
        
        return cell
    }
}
