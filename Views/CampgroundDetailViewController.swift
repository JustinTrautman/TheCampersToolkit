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
import Kingfisher

var shouldReloadReviews: Bool = false

class CampgroundDetailViewController: UIViewController {
    
    // MARK: - Properties
    var selectedCampground: Results?
    var campgroundDetails: Result?
    private var reviews: [Reviews]?
    private var campgroundsXml: [Campgroundxml]?
    private let geoCoder = CLGeocoder()
    
    // MARK: - Outlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var campgroundImageView: UIImageView!
    @IBOutlet weak private var campgroundNameLabel: UILabel!
    @IBOutlet weak private var navigationBarTitle: UINavigationItem!
    @IBOutlet weak private var campgroundRatingImageView: UIImageView!
    @IBOutlet weak private var reviewCountLabel: UILabel!
    @IBOutlet weak private var visitWebsiteButton: UIButton!
    @IBOutlet weak private var viewHoursButton: UIButton!
    @IBOutlet weak private var isOfficeOpenLabel: UILabel!
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var campgroundAddressLabel: UILabel!
    @IBOutlet weak private var directionsButton: UIButton!
    @IBOutlet weak private var reviewTableView: UITableView!
    @IBOutlet weak private var reviewTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var availabilityStatusLabel: UILabel!
    @IBOutlet weak private var reservationTypeLabel: UILabel!
    @IBOutlet weak private var campgroundTypeLabel: UILabel!
    @IBOutlet weak private var powerHookupsLabel: UILabel!
    @IBOutlet weak private var sewerHookupsLabel: UILabel!
    @IBOutlet weak private var waterHookupsLabel: UILabel!
    @IBOutlet weak private var waterViewsLabel: UILabel!
    @IBOutlet weak private var petsAllowedLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func reviewButtonTapped(_ sender: Any) {
        guard campgroundDetails?.reviews != nil else {
            AlertHelper.showNoReviewsFound(for: selectedCampground?.name ?? "This campground", on: self)
            return
        }
        
        let tableViewCenter = Int(scrollView.center.y) + 550
        scrollView.setContentOffset(CGPoint(x: 0, y: tableViewCenter), animated: true)
    }
    
    @IBAction func photosButtonTapped(_ sender: Any) {
        if campgroundDetails?.photos?.count == nil {
            let campgroundName = selectedCampground?.name ?? "This campground"
            AlertHelper.showNoPhotosFound(for: campgroundName, on: self)
            return
        }
        self.performSegue(withIdentifier: PhotosViewController.segueIdentifier, sender: self)
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        updateViews()
        fetchCampgroundPhoto()
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
    
    func fetchCampgroundPhoto() {
        guard let campgroundPhotoReference = campgroundDetails?.photos?.first?.photoReference else {
            return
        }
        
        let photoUrl = String().googlePhotosUrl(photoRef: campgroundPhotoReference, maxWidth: 300)
        let defaultImage = UIImage(named: "defaultCampgroundImage")
        let transition = ImageTransition.fade(0.2)
        
        DispatchQueue.main.async {
            self.campgroundImageView.kf.indicatorType = .activity
            self.campgroundImageView.kf.setImage(with: photoUrl, placeholder: defaultImage, options: [.transition(transition)])
        }
    }
    
    // TODO: Refactor this code
    func updateViews() {
        // Some initial view setup
        campgroundNameLabel.numberOfLines = 0
        campgroundAddressLabel.numberOfLines = 0
        
        reviewTableView.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CampgroundDetailViewController.tapFunction))
        phoneNumberLabel.addGestureRecognizer(tapGestureRecognizer)
        
        guard let campground = campgroundDetails else { return }
        
        DispatchQueue.main.async {
            if let campgroundName = campground.name {
                self.campgroundNameLabel.text = campgroundName
                self.navigationBarTitle.title = campgroundName
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
                    self.isOfficeOpenLabel.text = "Office is Open"
                case .closed:
                    self.isOfficeOpenLabel.text = "Office is Closed"
                case .empty:
                    break
                }
                
                self.isOfficeOpenLabel.isHidden = false
            }
            
            guard let campgroundRating = campground.rating else {
                return
            }
            let roundedRating = Double(campgroundRating).roundToClosestHalf()
            self.campgroundRatingImageView.image = StarRatingHelper.returnStarFrom(rating: roundedRating)
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
    
    // Gesture recogizer for phone number label. Presents the user with a prompt to complete the call.
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        guard let numberToCall = phoneNumberLabel.text?.replacingOccurrences(of: " ", with: "") else { return }
        
        OpenUrlHelper.call(phoneNumber: numberToCall)
    }
    
    // MARK: - Navigation
    // TODO: Implement a switch statement for segue identifiers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ReviewDetailViewController.segueIdentifier {
            if let indexPath = self.reviewTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as?
                    ReviewDetailViewController else { return }
                
                var review: Reviews
                
                if shouldReloadReviews == true {
                    guard let campgroundReviews = reviews else { return }
                    review = campgroundReviews[indexPath.row]
                    
                    detailVC.review = review
                } else {
                    guard let campgroundReviews = GoogleDetailController.campgrounds?.reviews else { return }
                    review = campgroundReviews[indexPath.row]
                    
                    detailVC.review = review
                }
            }
        }
        
        if segue.identifier == WeatherViewController.segueIdentifier {
            guard let detailVC = segue.destination as?
                WeatherViewController else { return }
            detailVC.campgroundDetails = sender as? Result
            detailVC.currentWeatherData = sender as? CampgroundWeatherData
            detailVC.address = campgroundDetails?.formattedAddress
        }
        
        if segue.identifier == HikingViewController.segueIdentifier {
            guard let detailVC = segue.destination as? HikingViewController,
                let searchText = campgroundAddressLabel.text else { return }
            
            // TODO: Move to extension
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
        
        if segue.identifier == PhotosViewController.segueIdentifier {
            guard let detailVC = segue.destination as? PhotosViewController else { return }
            
            detailVC.photoReferences = campgroundDetails?.photos
        }
        
        if segue.identifier == HoursViewController.segueIdentifier {
            guard let detailVC = segue.destination as?
                HoursViewController else { return }
            
            detailVC.hours = campgroundDetails?.openingHours
        }
        
        if segue.identifier == TravelViewController.segueIdentifier {
            guard let detailVC = segue.destination as? TravelViewController,
                let selectedCampground = selectedCampground else { return }
            
            let latitude = selectedCampground.geometry?.location?.lat ?? 0
            let longitude = selectedCampground.geometry?.location?.lng ?? 0
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            detailVC.campgroundAmmenities = true
            detailVC.campgroundCoordinates = coordinates
        }
        
        if segue.identifier == SatelliteViewController.segueIdentifier {
            guard let detailVC = segue.destination as? SatelliteViewController else { return }
            
            detailVC.selectedCampground = selectedCampground
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

