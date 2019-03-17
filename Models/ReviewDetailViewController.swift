/*
 ----------------------------------------------------------------------------------------
 
 ReviewDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/23/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import Kingfisher

class ReviewDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var reviewerProfileImage: UIImageView!
    @IBOutlet weak private var reviewerNameLabel: UILabel!
    @IBOutlet weak private var ratingImageView: UIImageView!
    @IBOutlet weak private var reviewTimestamp: UILabel!
    @IBOutlet weak private var reviewTextView: UITextView!
    
    // MARK: - Properties
    var review: Reviews?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func updateViews() {
        guard let review = review else { return }
        
        if let photoURL = review.profilePhotoUrl {
            self.reviewerProfileImage.kf.indicatorType = .activity
            self.reviewerProfileImage.kf.setImage(with: URL(string: photoURL), options: [.transition(ImageTransition.fade(0.2))])
        }
        
        if let campgroundRating = review.rating {
            let roundedRating = Double(campgroundRating).roundToClosestHalf()
            self.ratingImageView.image = StarRatingHelper.returnStarFrom(rating: roundedRating)
        }
        
        reviewerNameLabel.text = review.authorName
        reviewTextView.text = review.text
        reviewTimestamp.text = review.relativeTimeDescription
    }
}

