/*
 ----------------------------------------------------------------------------------------
 
 AmenityDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/9/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 TODO: Fix default image
 TODO: Fix amenity typo
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import MapKit

class AmenityDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var amenityImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var openUntilLabel: UILabel!
    @IBOutlet weak var amenityPhoneNumberButton: UIButton!
    @IBOutlet weak var amenityRatingImageView: UIImageView!
    @IBOutlet weak var amenityMapView: GMSMapView!
    @IBOutlet weak var takeMeHereButton: UIButton!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    
    // MARK: - Properties
    var amenitieDetails: Result?
    var photoReference: String?
    var selectedAmenity: String?
    
    let geoCoder = CLGeocoder()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button will be disabled unless amenity has a url from Google
        visitWebsiteButton.isEnabled = false
        
        fetchAmenityDetails()
    }
    
    // MARK: - Actions
    // TODO: - DRY; give make navigation logic its own object
    @IBAction func takeMeHereButtonTapped(_ sender: Any) {
        guard let address = amenitieDetails?.formattedAddress,
            let title = amenitieDetails?.name else { return }
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
            
            if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                let url = URL(string: "comgooglemaps://?daddr=\(location.latitude),\(location.longitude)&directionsmode=driving")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Opening in Apple Maps")
                
                let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
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
    }
    
    @IBAction func phoneNumberButtonTapped(_ sender: Any) {
        guard let numberToCall = amenityPhoneNumberButton.currentTitle?.replacingOccurrences(of: " ", with: "") else { return }
        if let phoneURL = URL(string: "telprompt://\(numberToCall)") {
            UIApplication.shared.canOpenURL(phoneURL)
            UIApplication.shared.open(phoneURL)
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: Any) {
        guard let url = amenitieDetails?.website else { return }
        openWebsiteUrl(url: url)
    }

    func fetchAmenityDetails() {
        guard let placeID = selectedAmenity else { return }
        
        GoogleDetailController.fetchPlaceDetailsWith(placeId: placeID) { (details) in
            if let details = details {
                self.amenitieDetails = details
                
                if let photos = details.photos {
                    for photo in photos {
                        self.photoReference = photo.photoReference
                    }
                }
                
                self.updateViews()
                self.loadMiniMap()
            }
        }
    }
    
    func fetchAmenityPhoto() {
        guard let selectedType = GooglePlaceSearchController.selectedType else { return }
        
        DispatchQueue.main.async {
            self.amenityImageView.image = UIImage(named: "\(selectedType)"+"PlaceholderImage")
        }
        
        if let photoReference = photoReference {
            GoogleDetailController.fetchCampgroundPhotosWith(photoReference: photoReference) { (fetchedImage) in
                DispatchQueue.main.async {
                    if let fetchedImage = fetchedImage {
                        DispatchQueue.main.async {
                            self.amenityImageView.image = fetchedImage
                        }
                    }
                }
            }
        }
    }
    
    func updateViews() {
        // Take me here button setup
        DispatchQueue.main.async {
            self.takeMeHereButton.layer.cornerRadius = 10.0
            self.takeMeHereButton.clipsToBounds = true
            self.takeMeHereButton.layer.shadowRadius = 3.0
            self.takeMeHereButton?.layer.shadowColor = UIColor.black.cgColor
            self.takeMeHereButton?.layer.shadowOpacity = 1.0
            self.takeMeHereButton?.layer.shadowOffset = CGSize(width: 5, height: 5)
            self.takeMeHereButton?.layer.masksToBounds = false
            self.takeMeHereButton?.backgroundColor = UIColor(displayP3Red: 0.07, green: 0.68, blue: 0.63, alpha: 1.00)
            self.takeMeHereButton?.setTitle("Take me here", for: .normal)
            self.takeMeHereButton?.setTitleColor(.white, for: .normal)
            self.takeMeHereButton?.titleLabel?.font = UIFont(name: "Helvetica", size: 18)
        }
        
        // UI updated from network configuration
        self.fetchAmenityPhoto()
        
        if let name = amenitieDetails?.name {
            DispatchQueue.main.async {
                self.placeNameLabel.text = name
            }
        }
        
        if let phoneNumber = amenitieDetails?.formattedPhoneNumber {
            DispatchQueue.main.async {
                self.amenityPhoneNumberButton.setTitle(phoneNumber, for: .normal)
                self.amenityPhoneNumberButton.setTitleColor(.blue, for: .normal)
            }
        }
        
        if let _ = amenitieDetails?.website {
            DispatchQueue.main.async {
                self.visitWebsiteButton.isEnabled = true
                self.visitWebsiteButton.setTitleColor(.black, for: .normal)
            }
        }
        
        guard let hoursOfOperation = amenitieDetails?.openingHours else { return }
        
        let dayOfWeek = Date().dayOfWeek()!
        
        if let _ = hoursOfOperation.weekdayText {
            print("Showing hours for \(dayOfWeek)")
            
            if dayOfWeek == "Sunday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Monday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Tuesday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Wednesday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Thursday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Friday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
            
            if dayOfWeek == "Saturday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                DispatchQueue.main.async {
                    self.openUntilLabel.text = "\(closingTime)"
                }
            }
        }
        
        if let amenityRating = amenitieDetails?.rating {
            let roundedRating = Double(amenityRating).roundToClosestHalf()
            
            // TODO: - Move Switch statement off of main thread.
            DispatchQueue.main.async {
                switch roundedRating {
                case 0:
                    self.amenityRatingImageView.image = UIImage(named: "0Stars")
                case 1:
                    self.amenityRatingImageView.image = UIImage(named: "1Stars")
                case 1.5:
                    self.amenityRatingImageView.image = UIImage(named: "1.5Stars")
                case 2:
                    self.amenityRatingImageView.image = UIImage(named: "2Stars")
                case 2.5:
                    self.amenityRatingImageView.image = UIImage(named: "2.5Stars")
                case 3:
                    self.amenityRatingImageView.image = UIImage(named: "3Stars")
                case 3.5:
                    self.amenityRatingImageView.image = UIImage(named: "3.5Stars")
                case 4:
                    self.amenityRatingImageView.image = UIImage(named: "4Stars")
                case 4.5:
                    self.amenityRatingImageView.image = UIImage(named: "4.5Stars")
                case 5:
                    self.amenityRatingImageView.image = UIImage(named: "5Stars")
                default:
                    self.amenityRatingImageView.image = UIImage(named: "0Stars")
                }
            }
        }
    }
    
    func openWebsiteUrl(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func returnClosingTime(forDay: String) -> String {
        guard let hoursOfOperation = amenitieDetails?.openingHours?.weekdayText else { return "" }
        var hoursString: String!
        
        if forDay == "Monday" {
            hoursString = "\(hoursOfOperation[0])"
        }
        
        if forDay == "Tuesday" {
            hoursString = "\(hoursOfOperation[1])"
        }
        
        if forDay == "Wednesday" {
            hoursString = "\(hoursOfOperation[2])"
        }
        
        if forDay == "Thursday" {
            hoursString = "\(hoursOfOperation[3])"
        }
        
        if forDay == "Friday" {
            hoursString = "\(hoursOfOperation[4])"
        }
        
        if forDay == "Saturday" {
            hoursString = "\(hoursOfOperation[5])"
        }
        
        if forDay == "Sunday" {
            hoursString = "\(hoursOfOperation[6])"
        }
        
        if let hours = hoursString.range(of: "– ") {
            let closingHour = hoursString[hours.upperBound...]
            
            return "Open until \(closingHour)"
        }
        
        if hoursString.contains("Open 24 hours") {
            return "Open 24 hours"
        }
        
        return hoursString
    }
    
    func loadMiniMap() {
        guard let address = amenitieDetails?.formattedAddress,
            let title = amenitieDetails?.name, let selectedType = GooglePlaceSearchController.selectedType else { return }
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
            
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: 14)
            self.amenityMapView.camera = camera
            self.amenityMapView.mapType = GMSMapViewType.normal
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = title
            marker.snippet = address
            marker.icon = UIImage(named: "\(selectedType)_pin")
            marker.map = self.amenityMapView
        }
    }
}

extension Date {
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
