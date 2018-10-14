/*
 ----------------------------------------------------------------------------------------
 
 CampgroundDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ✔ TODO: - do didTap() functions for phoneNumberLabel and directionsLabel
 ✔ TODO: Test the case of no reviews with new campground fetch function. Verify it doesn't crash.
 ----------------------------------------------------------------------------------------
 */

import UIKit
import MapKit

class CampgroundDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var campgroundImageView: UIImageView!
    @IBOutlet weak var campgroundNameLabel: UILabel!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var campgroundRatingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var viewHoursButton: UIButton!
    @IBOutlet weak var isOfficeOpenLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var campgroundAddressLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var availabilityStatusLabel: UILabel!
    @IBOutlet weak var reservationTypeLabel: UILabel!
    @IBOutlet weak var campgroundTypeLabel: UILabel!
    @IBOutlet weak var powerHookupsLabel: UILabel!
    @IBOutlet weak var sewerHookupsLabel: UILabel!
    @IBOutlet weak var waterHookupsLabel: UILabel!
    @IBOutlet weak var waterViewsLabel: UILabel!
    @IBOutlet weak var petsAllowedLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func reviewButtonTapped(_ sender: Any) {
        let tableViewCenter = Int(scrollView.center.y) + 550
        
        scrollView.setContentOffset(CGPoint(x: 0, y: tableViewCenter), animated: true)
    }
    
    @IBAction func visitWebsiteButtonTapped(_ sender: Any) {
        guard let url = campgrounds?.website else { return }
        openWebsiteUrl(url: url)
    }
    
    // MARK: - Properties
//    var googlePlaces: [Results]?
    var selectedCampground: Results?
    var campgrounds: Result?
    var reviews: [Reviews]?
    var photos: [Photos]?
    var xmlCampgrounds: [Campgroundxml]?
    
    let geoCoder = CLGeocoder()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
//        fetchFromActiveApi()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        // Buttons are only enabled when data is available
        visitWebsiteButton.isEnabled = false
        visitWebsiteButton.setTitleColor(.gray, for: .disabled)
        viewHoursButton.isEnabled = false
        viewHoursButton.setTitleColor(.gray, for: .disabled)
    }
    
    // TODO: - DRY; give make navigation logic its own object
    @IBAction func directionsButtonTapped(_ sender: Any) {
        guard let address = campgrounds?.formattedAddress,
            let title = campgrounds?.name else { return }
        
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
    
//    func fetchFromActiveApi() {
//        guard let foundCampgrounds = googlePlaces else { return }
//        for campground in foundCampgrounds {
//            let campgroundName = campground.name
//            let campgroundParser = CampgroundParser()
//            campgroundParser.parseCampground(url: "http://api.amp.active.com/camping/campgrounds/?pname=\(campgroundName)&api_key=\(Constants.activeApiKey)") { (campgroundxml) in
//                print("http://api.amp.active.com/camping/campgrounds/?pname=\(campgroundName)&api_key=\(Constants.activeApiKey)")
//
//                print(campgroundxml)
//                self.xmlCampgrounds = campgroundxml
//            }
//        }
//    }
    
    func updateViews() {
        guard let selectedCampground = selectedCampground else { return }
        
        // Some initial view setup
        campgroundNameLabel.numberOfLines = 0
        campgroundAddressLabel.numberOfLines = 0
        
        reviewTableView.tableFooterView = UIView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CampgroundDetailViewController.tapFunction))
        phoneNumberLabel.addGestureRecognizer(tap)
        
        // Updates from Google Place API
            let campgroundID = selectedCampground.placeID ?? ""
            print(campgroundID)
            
            // TODO: Set image passed from HomeVC
            
            //        if let campgroundImage = campground?.photo {
            //            campgroundImageView.image = campgroundImage
            //        }
            
            // Updates from Google Place Details API
            GoogleDetailController.fetchPlaceDetailsWith(placeId: campgroundID) { (campground) in
                if let campground = campground {
                    self.campgrounds = campground
                    
                    DispatchQueue.main.async {
                        self.loadReviews()
                        
                        if let campgroundName = campground.name {
                            self.campgroundNameLabel.text = campgroundName
                            self.navigationTitle.title = campgroundName
                        }
                        
                        if let phoneNumber = self.campgrounds?.formattedPhoneNumber {
                            self.phoneNumberLabel.text = phoneNumber
                            self.phoneNumberLabel.textColor = .blue
                        }
                        
                        if let campgroundAdress = self.campgrounds?.formattedAddress {
                            self.campgroundAddressLabel.text = campgroundAdress
                        }
                        
                        if let campgroundReviews = self.campgrounds?.reviews {
                            self.reviewCountLabel.text = "(\(campgroundReviews.count))"
                        }
                        
                        if let _ = self.campgrounds?.website {
                            self.visitWebsiteButton.isEnabled = true
                        }
                        
                        if self.campgrounds?.openingHours?.openNow == true {
                            self.isOfficeOpenLabel.text = "Office open now"
                        }
                        
                        if self.campgrounds?.openingHours?.openNow == false {
                            self.isOfficeOpenLabel.text = "Office closed now"
                            
                        }
                        
                        if self.campgrounds?.openingHours?.openNow == nil {
                            self.isOfficeOpenLabel.text = ""
                        }
                        
                        guard let campgroundRating = self.campgrounds?.rating else { return }
                        
                        let roundedRating = Double(campgroundRating).roundToClosestHalf()
                        
                        switch roundedRating {
                        case 0:
                            self.campgroundRatingImageView.image = UIImage(named: "0Stars")
                        case 1:
                            self.campgroundRatingImageView.image = UIImage(named: "1Stars")
                        case 1.5:
                            self.campgroundRatingImageView.image = UIImage(named: "1.5Stars")
                        case 2:
                            self.campgroundRatingImageView.image = UIImage(named: "2Stars")
                        case 2.5:
                            self.campgroundRatingImageView.image = UIImage(named: "2.5Stars")
                        case 3:
                            self.campgroundRatingImageView.image = UIImage(named: "3Stars")
                        case 3.5:
                            self.campgroundRatingImageView.image = UIImage(named: "3.5Stars")
                        case 4:
                            self.campgroundRatingImageView.image = UIImage(named: "4Stars")
                        case 4.5:
                            self.campgroundRatingImageView.image = UIImage(named: "4.5Stars")
                        case 5:
                            self.campgroundRatingImageView.image = UIImage(named: "5Stars")
                        default:
                            self.campgroundRatingImageView.image = UIImage(named: "0Stars")
                        }
                        
                        if let _ = self.campgrounds?.openingHours {
                            self.viewHoursButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    func loadReviews() {
        DispatchQueue.main.async {
            self.reviewTableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewDetail" {
            if let indexPath = self.reviewTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as?
                    ReviewDetailViewController else { return }
                
                guard let googleReviews = GoogleDetailController.campgrounds?.reviews else { return }
                let review = googleReviews[indexPath.row]
                
                detailVC.reviews = review
            }
        }
        
        if segue.identifier == "weatherDetail" {
            guard let detailVC = segue.destination as?
                WeatherViewController else { return }
            detailVC.campgrounds = sender as? Result
            detailVC.weather = sender as? CampgroundWeatherData
            detailVC.address = campgrounds?.formattedAddress
        }
        
        if segue.identifier == "toHikingResults" {
            guard let detailVC = segue.destination as? HikingViewController,
                let searchText = campgroundAddressLabel.text else { return }
            
            geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
                
                let latitude = location.latitude
                let longitude = location.longitude
                
                HikingTrailController.fetchHikingTrailsNear(latitude: "\(latitude)", longitude: "\(longitude)") { (trails) in
                    if let _ = trails {
                        DispatchQueue.main.async {
                            detailVC.hikingSearchBar.text = searchText
                            detailVC.searchBarSearchButtonClicked(detailVC.hikingSearchBar)
                        }
                    }
                }
            }
        }
        
        if segue.identifier == "photoDetail" {
            guard let detailVC = segue.destination as? CampgroundPhotosViewController else { return }
            
            detailVC.photos = campgrounds?.photos
            
            if campgrounds?.photos?.count == nil {
                showNoPhotosAlert()
            }
        }
        
        if segue.identifier == "toHoursVC" {
            guard let detailVC = segue.destination as?
                CampgroundHoursViewController else { return }
            
            detailVC.hours = campgrounds
        }
        
        if segue.identifier == "toCamgroundAmenityVC" {
            guard let detailVC = segue.destination as? TravelViewController,
                let selectedCampground = selectedCampground else { return }
            
                let latitude = selectedCampground.geometry?.location?.lat ?? 0
                let longitude = selectedCampground.geometry?.location?.lng ?? 0
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                detailVC.campgroundAmmenities = true
                detailVC.campgroundCoordinates = coordinates
        }
        
        if segue.identifier == "toCampgroundMapView" {
            guard let detailVC = segue.destination as? SatelliteViewController else { return }
            
            detailVC.selectedCampground = selectedCampground
        }
    }
    
    // Gesture recogizer for phone number label. Presents the user with a prompt to complete the call.
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        guard let numberToCall = phoneNumberLabel.text?.replacingOccurrences(of: " ", with: "") else { return }
        if let phoneURL = URL(string: "telprompt://\(numberToCall)") {
            UIApplication.shared.canOpenURL(phoneURL)
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    func openWebsiteUrl(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func showNoPhotosAlert() {
        if let campgroundName = campgrounds?.name {
            let noPhotosAlert = UIAlertController(title: nil, message: "\(campgroundName) has no photos", preferredStyle: .alert)
            noPhotosAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(noPhotosAlert, animated: true)
        }
    }
}

extension CampgroundDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let unwrappedReviews = GoogleDetailController.campgrounds?.reviews else { return 0 }
        
        return unwrappedReviews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as?
            CampgroundReviewCell else { return UITableViewCell() }
        
        guard let unwrappedReviews = GoogleDetailController.campgrounds?.reviews else { return UITableViewCell() }
        
        let review = unwrappedReviews[indexPath.row]
        cell.reviews = review
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reviewTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        reviewTableView.deselectRow(at: indexPath, animated: true)
    }
}

