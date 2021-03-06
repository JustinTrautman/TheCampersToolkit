/*
 ----------------------------------------------------------------------------------------
 
 AmenityDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/9/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import Kingfisher

class AmenityDetailViewController: UIViewController, SFSafariViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak private var amenityImageView: UIImageView!
    @IBOutlet weak private var placeNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak private var websiteLabel: UILabel!
    @IBOutlet weak private var ratingImageView: UIImageView!
    @IBOutlet weak private var openUntilLabel: UILabel!
    @IBOutlet weak private var viewMoreHoursButton: UIButton!
    @IBOutlet weak private var amenityMapView: GMSMapView!
    @IBOutlet weak private var takeMeHereButton: UIButton!
    
    // MARK: - Properties
    var amenitieDetails: Result?
    var photoReference: String?
    var selectedAmenity: String?
    
    private let geoCoder = CLGeocoder()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAmenityDetails()
        
        phoneNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhoneLabelTap)))
        websiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWebsiteLabelTap)))
        amenityImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAmenityImageTap)))
    }
    
    // MARK: - Actions
    @IBAction func takeMeHereButtonTapped(_ sender: Any) {
        guard let address = amenitieDetails?.formattedAddress,
            let amenityName = amenitieDetails?.name else { return }
        
        OpenUrlHelper.openNavigationApp(withAddress: address, orCoordinates: nil, mapItemName: amenityName)
    }
    
    
    func fetchAmenityDetails() {
        guard let placeID = selectedAmenity else { return }
        
        GoogleDetailController.fetchPlaceDetailsWith(placeId: placeID) { (details) in
            if let details = details {
                self.amenitieDetails = details
                
                if let photos = details.photos {
                    self.photoReference = photos.first?.photoReference
                }
                
                self.fetchAmenityPhoto()
                self.updateViews()
                self.loadMiniMap()
            }
        }
    }
    
    func fetchAmenityPhoto() {
        if let photoReference = photoReference {
            let photoUrl = String().googlePhotosUrl(photoRef: photoReference, maxWidth: 300)
            let defaultImage = UIImage(named: "noImageAvailable")
            let transition = ImageTransition.fade(0.2)
            
            DispatchQueue.main.async {
                self.amenityImageView.kf.indicatorType = .activity
                self.amenityImageView.kf.setImage(with: photoUrl, placeholder: defaultImage, options: [.transition(transition)])
                self.amenityImageView.isUserInteractionEnabled = true
            }
        }
    }
    
    func updateViews() {
        guard let amenity = amenitieDetails else {
            assertionFailure()
            return
        }
        
        let name = amenity.name ?? "Unknown Name"
        let phoneNumber = amenity.formattedPhoneNumber ?? "No phone number"
        let website = amenity.website ?? "No website"
        let starRating = amenity.rating?.roundToClosestHalf() ?? 0
        let todaysDate = Date().dayOfWeek()!
        let businessHours = amenity.openingHours?.weekdayText ?? ["Business hours unknown"]
        
        DispatchQueue.main.async {
            self.placeNameLabel.text = name
            self.phoneNumberLabel.text = phoneNumber
            self.ratingImageView.image = StarRatingHelper.returnStarFrom(rating: starRating)
            self.openUntilLabel.text = HoursHelper.returnClosingTime(for: businessHours, on: todaysDate)
            self.takeMeHereButton.applyGreenTheme(buttonTitle: "Take me here")
            
            // Enable website and more hours labels if infomation is present
            switch phoneNumber {
            case "No phone number":
                self.phoneNumberLabel.textColor = .gray
            default:
                self.phoneNumberLabel.textColor = .blue
                self.phoneNumberLabel.isUserInteractionEnabled = true
            }
            
            switch website {
            case "No website", "":
                self.websiteLabel.text = "No website"
                self.websiteLabel.textColor = .gray
                break
            default:
                self.websiteLabel.text = "Visit website"
                self.websiteLabel.textColor = .blue
                self.websiteLabel.isUserInteractionEnabled = true
            }
            
            switch businessHours {
            case ["Business hours unknown"]:
                return
            default:
                self.viewMoreHoursButton.isUserInteractionEnabled = true
                self.viewMoreHoursButton.setTitleColor(.blue, for: .normal)
            }
        }
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case PhotoDetailViewController.segueIdentifier:
            guard let destinationVC = segue.destination as? PhotoDetailViewController else {
                return
            }
            destinationVC.photo = amenityImageView.image
            
        case HoursViewController.segueIdentifier:
            guard let destinationVC = segue.destination as? HoursViewController,
                let hours = amenitieDetails?.openingHours else {
                    return
            }
            destinationVC.hours = hours
            
        default:
            preconditionFailure("Segue identifier: \(String(describing: segue.identifier)) not found or incorrectly implemented.")
        }
    }
}

