/*
 ----------------------------------------------------------------------------------------
 
 CampgroundDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import MapKit
import SafariServices
import Cosmos

/*
 TODO: -
 Insert a default cell into table view if api call returns no reviews
 */

var shouldReloadReviews: Bool = false

class CampgroundDetailViewController: UIViewController, SFSafariViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var campgroundImageView: UIImageView!
    @IBOutlet weak var campgroundNameLabel: UILabel!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var ratingView: CosmosView!
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
    @IBOutlet weak var reviewTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var campgroundTypeLabel: UILabel!
    @IBOutlet weak var powerHookupsLabel: UILabel!
    @IBOutlet weak var sewerHookupsLabel: UILabel!
    @IBOutlet weak var waterHookupsLabel: UILabel!
    @IBOutlet weak var waterViewsLabel: UILabel!
    @IBOutlet weak var petsAllowedLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func reviewButtonTapped(_ sender: Any) {
        let tableViewCenter = Int(scrollView.center.y) + 390
        
        scrollView.setContentOffset(CGPoint(x: 0, y: tableViewCenter), animated: true)
    }
    
    @IBAction func visitWebsiteButtonTapped(_ sender: Any) {
        guard let url = campgroundDetails?.website else { return }
        
        OpenUrlHelper.openWebsite(with: url, on: self)
    }
    

    @IBAction func directionsButtonTapped(_ sender: Any) {
        guard let address = campgroundDetails?.formattedAddress,
            let markerName = campgroundDetails?.name else { return }
        
        OpenUrlHelper.openNavigationApp(withAddress: address, orCoordinates: nil, mapItemName: markerName)
    }
    
    // MARK: - Properties
    var selectedCampground: Results?
    var campgroundDetails: Result?
    var reviews: [Reviews]?
    var selectedReview: Reviews?
    var campgroundsXml: [Campgroundxml]?
    var campgroundPhoto: UIImage?
    var photosArray: [Photos]?
    
    let geoCoder = CLGeocoder()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        updateViews()
        fetchFromActiveApi()
        loadReviews()
        listenForUnwindSegue()
        
        // Buttons are only enabled when data is available
        visitWebsiteButton.isEnabled = false
        visitWebsiteButton.setTitleColor(.gray, for: .disabled)
        viewHoursButton.isEnabled = false
        viewHoursButton.setTitleColor(.gray, for: .disabled)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
            self.reviewTableViewHeight.constant = self.reviewTableView.contentSize.height
        }
    }

    func fetchFromActiveApi() {
        guard let selectedCampground = selectedCampground,
            let campgroundName = selectedCampground.name else { return }
        
        let campgroundParser = CampgroundParser()
        campgroundParser.parseCampground(url: "http://api.amp.active.com/camping/campgrounds/?pname=\(campgroundName)&api_key=\(Constants.activeApiKey)") { (campgroundxml) in
            print("http://api.amp.active.com/camping/campgrounds/?pname=\(campgroundName)&api_key=\(Constants.activeApiKey)")
            print(campgroundxml)
            
            self.campgroundsXml = campgroundxml
        }
    }
    
    func updateViews() {
        // Some initial view setup
        campgroundNameLabel.numberOfLines = 0
        campgroundAddressLabel.numberOfLines = 0
        
        reviewTableView.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CampgroundDetailViewController.tapFunction))
        phoneNumberLabel.addGestureRecognizer(tapGestureRecognizer)
        
        // Updates from Google Place API
        if let campgroundPhoto = campgroundPhoto {
            campgroundImageView.image = campgroundPhoto
        }
        
        guard let campground = campgroundDetails else { return }
        
        DispatchQueue.main.async {
            if let campgroundName = campground.name {
                self.campgroundNameLabel.text = campgroundName
                self.navigationTitle.title = campgroundName
            }
            
            if let phoneNumber = campground.formattedPhoneNumber {
                self.phoneNumberLabel.text = phoneNumber
                self.phoneNumberLabel.textColor = .blue
            }
            
            if let campgroundAddress = campground.formattedAddress {
                self.campgroundAddressLabel.text = campgroundAddress
            }
            
            if let campgroundReviews = campground.reviews {
                self.reviewCountLabel.text = "(\(campgroundReviews.count))"
            }
            
            if let _ = campground.website {
                self.visitWebsiteButton.isEnabled = true
            }
            
            if let campgroundHours = campground.openingHours {
                self.viewHoursButton.isEnabled = true
                
                let isOfficeOpen = "\(campgroundHours.openNow ?? Bool())" 
                
                guard let isOpen = IsOpen(rawValue: isOfficeOpen) else { return }
                
                switch isOpen {
                case .open:
                    self.isOfficeOpenLabel.text = "Office Open Now"
                case .closed:
                    self.isOfficeOpenLabel.text = "Office Closed Now"
                case .empty:
                    self.isOfficeOpenLabel.text = ""
                }
            }
            
            guard let campgroundRating = campground.rating else { return }
            let roundedRating = Double(campgroundRating).roundToClosestHalf()
            
            switch roundedRating {
            case 1:
                self.ratingView.rating = 0
            case 1.5:
                self.ratingView.rating = 1.5
            case 2:
                self.ratingView.rating = 2
            case 2.5:
                self.ratingView.rating = 2.5
            case 3:
                self.ratingView.rating = 3
            case 3.5:
                self.ratingView.rating = 3.5
            case 4:
                self.ratingView.rating = 4
            case 4.5:
                self.ratingView.rating = 4.5
            case 5:
                self.ratingView.rating = 5
            default:
                self.ratingView.rating = 0
            }
        }
    }
    
    func loadReviews() {
        DispatchQueue.main.async {
            self.reviewTableView.reloadData()
        }
    }
    
    func listenForUnwindSegue() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateReviewsAfterUnwind(notification:)), name: Constants.updateReviewsKey, object: nil)
    }
    
    @objc func updateReviewsAfterUnwind(notification: NSNotification) {
        guard let placeId = selectedCampground?.placeID else {
            return
        }
        
        shouldReloadReviews = true
        
        GoogleDetailController.fetchPlaceReviewsWith(placeId: placeId) { (reviews) in
            if let reviews = reviews {
                self.reviews = reviews
            }
            
            self.loadReviews()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewDetail" {
            if let indexPath = self.reviewTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as?
                    ReviewDetailViewController else { return }
                
                if shouldReloadReviews == true {
                    guard let campgroundReviews = reviews else { return }
                    selectedReview = campgroundReviews[indexPath.row]
                    
                    detailVC.reviews = selectedReview
                } else {
                    guard let campgroundReviews = GoogleDetailController.campgrounds?.reviews else { return }
                    selectedReview = campgroundReviews[indexPath.row]
                    
                    detailVC.reviews = selectedReview
                }
            }
        }
        
        if segue.identifier == "toWeatherDetail" {
            guard let detailVC = segue.destination as?
                WeatherViewController else { return }
            detailVC.campgroundDetails = sender as? Result
            detailVC.currentWeatherData = sender as? CampgroundWeatherData
            detailVC.address = campgroundDetails?.formattedAddress
        }
        
        if segue.identifier == "toHikingTrails" {
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
        
        if segue.identifier == "toPhotosDetail" {
            guard let detailVC = segue.destination as? CampgroundPhotosViewController else { return }
    
            detailVC.photoReferences = photosArray
            
            if campgroundDetails?.photos?.count == nil {
                showNoPhotosAlert()
            }
        }
        
        if segue.identifier == "toHoursVC" {
            guard let detailVC = segue.destination as?
                CampgroundHoursViewController else { return }
            
            detailVC.hours = campgroundDetails
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
        
        OpenUrlHelper.call(phoneNumber: numberToCall)
    }
    
    func showNoPhotosAlert() {
        if let campgroundName = campgroundDetails?.name {
            let noPhotosAlert = UIAlertController(title: nil, message: "\(campgroundName) doesn't have any photos", preferredStyle: .alert)
            noPhotosAlert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
            
            self.present(noPhotosAlert, animated: true)
        }
    }
}

extension CampgroundDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldReloadReviews == true {
            guard let reviews = reviews else {
                return 0
            }
            return reviews.count
        } else {
            guard let reviews = GoogleDetailController.campgrounds?.reviews else {
                return 0
            }
            return reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as?
            CampgroundReviewCell else { return UITableViewCell() }
        
        if shouldReloadReviews == true {
            guard let reviews = reviews else {
                return UITableViewCell()
            }
            
            let review = reviews[indexPath.row]
            cell.reviews = review
            updateViewConstraints()
            
            return cell
        } else {
            guard let reviews = GoogleDetailController.campgrounds?.reviews else {
                return UITableViewCell()
            }
            
            let review = reviews[indexPath.row]
            cell.reviews = review
            updateViewConstraints()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reviewTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        reviewTableView.deselectRow(at: indexPath, animated: true)
    }
}

