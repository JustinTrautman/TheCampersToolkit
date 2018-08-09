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

class HikingDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trailImageView: UIImageView!
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var trailLocationLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var voteCounterLabel: UILabel!
    @IBOutlet weak var trailSummaryLabel: UILabel!
    @IBOutlet weak var trailLengthLabel: UILabel!
    @IBOutlet weak var trailAscentLabel: UILabel!
    @IBOutlet weak var trailDescentLabel: UILabel!
    @IBOutlet weak var trailHighPointLabel: UILabel!
    @IBOutlet weak var trailLowPointLabel: UILabel!
    @IBOutlet weak var trailConditionLabel: UILabel!
    @IBOutlet weak var conditionsUpdatedLabel: UILabel!
 
    // MARK: - Properties
    let scrollViewSize = CGSize(width: 375, height: 900)
    
    var trails: Trails? {
        didSet {
            print("trail was set")
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("called first")
        
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentOffset.x = 0
        scrollView.contentSize = scrollViewSize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("the will appear")
        updateViews()
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
        case 0:
            self.ratingImageView.image = UIImage(named: "0Stars")
        case 1:
            self.ratingImageView.image = UIImage(named: "1Stars")
        case 1.5:
            self.ratingImageView.image = UIImage(named: "1.5Stars")
        case 2:
            self.ratingImageView.image = UIImage(named: "2Stars")
        case 2.5:
            self.ratingImageView.image = UIImage(named: "2.5Stars")
        case 3:
            self.ratingImageView.image = UIImage(named: "3Stars")
        case 3.5:
            self.ratingImageView.image = UIImage(named: "3.5Stars")
        case 4:
            self.ratingImageView.image = UIImage(named: "4Stars")
        case 4.5:
            self.ratingImageView.image = UIImage(named: "4.5Stars")
        case 5:
            self.ratingImageView.image = UIImage(named: "5Stars")
        default:
            self.ratingImageView.image = UIImage(named: "0Stars")
        }
    }
}

