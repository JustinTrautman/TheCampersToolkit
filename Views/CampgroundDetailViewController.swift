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

class CampgroundDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var campgroundImageView: UIImageView!
    @IBOutlet weak var campgroundNameLabel: UILabel!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var campgroundRatingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var isOfficeOpenLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var campgroundAddressLabel: UILabel!
    @IBOutlet weak var campgroundWebsiteLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var mondayLabel: UILabel!
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
    
    @IBAction func photosButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func weatherButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func hikingButtonTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - Properties
    var campground: GooglePlace?
    var campgrounds: Result?
    var reviews: [Reviews]?
    var photos: [Photos]?
    
    var xmlCampgrounds: [Campgroundxml]?
    var test: Campgroundxml!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        fetchData()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadReviews()
        
    }

    
    func fetchData() {
        
        guard let campgroundName = campground?.name else { return }
        
        let campgroundParser = CampgroundParser()
        campgroundParser.parseCampground(url: "http://api.amp.active.com/camping/campgrounds/?pname=\(campgroundName)&api_key=\(Constants.activeApiKey)") { (campgroundxml) in
        
            print(campgroundxml)
            self.xmlCampgrounds = campgroundxml
        }
    }
    
    func updateViews() {
        
        // Some initial setup
        campgroundNameLabel.numberOfLines = 0
        campgroundAddressLabel.numberOfLines = 0
        reviewTableView.tableFooterView = UIView()
        campgroundWebsiteLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(CampgroundDetailViewController.tapFunction))
        campgroundWebsiteLabel.addGestureRecognizer(tap)
        
        // Updates from Google Place API
        guard let campgroundId = campground?.id else { return }
        
        if let campgroundImage = campground?.photo {
            campgroundImageView.image = campgroundImage
        }
        
        // Updates from Google Place Details API
        GoogleDetailController.fetchCampgroundDetailsWith(placeId: campgroundId) { (campground) in
            if let campground = campground {
                self.campgrounds = campground
                
                DispatchQueue.main.async {
                    
                    self.loadReviews()
                    
                    if let campgroundName = campground.name {
                        self.campgroundNameLabel.text = campgroundName
                        self.navigationTitle.title = campgroundName
                    }
                    
                    if let campgroundPhone = self.campgrounds?.formattedPhoneNumber {
                        self.phoneNumberLabel.text = campgroundPhone
                    }
                    
                    if let campgroundAdress = self.campgrounds?.formattedAddress {
                        self.campgroundAddressLabel.text = campgroundAdress
                    }
                    
                    if let campgroundReviews = self.campgrounds?.reviews {
                        self.reviewCountLabel.text = "(\(campgroundReviews.count))"
                    }
                    
                    if let campgroundWebsite = self.campgrounds?.website {
                        self.campgroundWebsiteLabel.text = campgroundWebsite
                        self.campgroundWebsiteLabel.textColor = .blue
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
                    
                    guard let hoursText = self.campgrounds?.openingHours?.weekdayText else { return }
                    
                    let cleanHoursString = "\(hoursText)".replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\"", with: "")
                    
                    self.mondayLabel.text = cleanHoursString
                    
//                    guard let availabilityStatus = self.test.availabilityStatus else { return }
//
//                    self.availabilityStatusLabel.text  = availabilityStatus
//
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
            guard let detailVC = segue.destination as? HikingViewController else { return }
            
            guard let searchText = campgroundAddressLabel.text else { return }
            let address = HikingViewController.shared.getLocationFromAddress(address: searchText)
            let latitude = "\(address.latitude)"
            let longitude = "\(address.longitude)"
            
            HikingTrailController.fetchHikingTrailsNear(latitude: latitude, longitude: longitude) { (trails) in
                if let _ = trails {
                    DispatchQueue.main.async {
                        detailVC.hikingSearchBar.text = searchText
                        detailVC.searchBarSearchButtonClicked(detailVC.hikingSearchBar)
                    }
                }
            }
        }
        
        if segue.identifier == "photoDetail" {
            guard let detailVC = segue.destination as? CampgroundPhotosViewController else { return }
            
            detailVC.photos = campgrounds?.photos
        }
    }
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        
        guard let website = campgroundWebsiteLabel.text else { return }
        
        openWebsiteUrl(url: website)
    }
    
    func openWebsiteUrl(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
}

extension Double {
    func roundToClosestHalf() -> Double {
        return Double(Int(self * 2)) / 2
    }
}

extension CampgroundDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let unwrappedReviews = GoogleDetailController.campgrounds?.reviews else { return 0 }

        return unwrappedReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as?
            CampgroundReviewCell else { return UITableViewCell() }
        
        guard let unwrappedReviews = GoogleDetailController.campgrounds?.reviews else { return UITableViewCell() }
        
        let review = unwrappedReviews[indexPath.row]
        cell.reviews = review
        return cell
    }
}
