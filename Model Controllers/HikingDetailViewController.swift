/*
 ----------------------------------------------------------------------------------------
 
 HikingDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/24/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import MapKit
import Cosmos

class HikingDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trailImageView: UIImageView!
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var trailLocationLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var voteCounterLabel: UILabel!
    @IBOutlet weak var trailSummaryLabel: UILabel!
    @IBOutlet weak var trailLengthLabel: UILabel!
    @IBOutlet weak var trailAscentLabel: UILabel!
    @IBOutlet weak var trailDescentLabel: UILabel!
    @IBOutlet weak var trailHighPointLabel: UILabel!
    @IBOutlet weak var trailLowPointLabel: UILabel!
    @IBOutlet weak var trailConditionLabel: UILabel!
    @IBOutlet weak var conditionsUpdatedLabel: UILabel!
    @IBOutlet weak var directionsToTrailsButton: UIButton!
    
    // MARK: - Properties
    let scrollViewSize = CGSize(width: 375, height: 900)
    
    var trails: Trails?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentOffset.x = 0
        scrollView.contentSize = scrollViewSize
        
        initializeTrailDirectionsButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func directionsToTrailButtonTapped(_ sender: Any) {
        guard let latitude = trails?.latitude,
            let longitude = trails?.longitude,
            let trailName = trails?.name else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        OpenUrlHelper.openNavigationApp(withAddress: nil, orCoordinates: coordinates, mapItemName: trailName)
    }
    
    func updateViews() {
        guard let trail = trails else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if let trailName = trail.name {
                self.trailNameLabel.text = trailName
            }
            
            if let trailLocation = trail.location {
                self.trailLocationLabel.text = trailLocation
            }
            
            if let voteCounter = trail.starVotes {
                if voteCounter == 1 {
                    self.voteCounterLabel.text = "(\(voteCounter) vote)"
                } else {
                    self.voteCounterLabel.text = "(\(voteCounter) votes)"
                }
            }
            
            if let conditionStatus = trail.conditionStatus  {
                if let conditionDetails = trail.conditionDetails {
                    self.trailConditionLabel.text = "\(conditionStatus) \(conditionDetails)"
                }
            }
            
            if let trailSummary = trail.summary {
                if trailSummary == "Needs Summary" {
                    self.trailSummaryLabel.text = "No Summary"
                } else {
                    self.trailSummaryLabel.text = trailSummary
                }
            }
            
            if let trailLength = trail.length {
                self.trailLengthLabel.text = "\(trailLength) miles"
            }
            
            if let trailAscent = trail.ascent {
                self.trailAscentLabel.text = "\(trailAscent) ft."
            }
            
            if let trailDescent = trail.descent {
                self.trailDescentLabel.text = "\(trailDescent) ft."
            }
            
            if let trailHighPoint = trail.high {
                self.trailHighPointLabel.text = "\(trailHighPoint) ft."
            }
            
            if let trailLowPoint = trail.low {
                self.trailLowPointLabel.text = "\(trailLowPoint) ft."
            }
            
            if let conditionUpdate = trail.conditionDate {
                self.conditionsUpdatedLabel.text = conditionUpdate
            }
        }
        
        guard let trailImage = trail.imgMedium else { return }
        
        HikingTrailController.fetchTrailImageWith(photoURL: trailImage) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.trailImageView.image = image
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        
        guard let trailRating = trail.stars else { return }
        
        let roundedRating = Double(trailRating).roundToClosestHalf()
        
        switch roundedRating {
        case 1:
            self.ratingView.rating = 1
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
    
    func initializeTrailDirectionsButton() {
        directionsToTrailsButton?.layer.cornerRadius = 10.0
        directionsToTrailsButton?.clipsToBounds = true
        directionsToTrailsButton?.layer.shadowRadius = 3.0
        directionsToTrailsButton?.layer.shadowColor = UIColor.black.cgColor
        directionsToTrailsButton?.layer.shadowOpacity = 1.0
        directionsToTrailsButton?.layer.shadowOffset = CGSize(width: 5, height: 5)
        directionsToTrailsButton?.layer.masksToBounds = false
        directionsToTrailsButton?.backgroundColor = UIColor(displayP3Red: 0.07, green: 0.68, blue: 0.63, alpha: 1.00)
        directionsToTrailsButton?.setTitle("Directions to this trail", for: .normal)
        directionsToTrailsButton?.setTitleColor(.white, for: .normal)
        directionsToTrailsButton?.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
    }
}

