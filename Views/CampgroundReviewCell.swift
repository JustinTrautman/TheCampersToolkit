/*
 ----------------------------------------------------------------------------------------
 
 CampgroundReviewCell.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import Kingfisher

class CampgroundReviewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var reviewerProfileImageView: UIImageView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var reviewTimestampLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
        
    var reviews: Reviews? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let reviews = reviews else { return }
        
        reviewerNameLabel.text = reviews.authorName
        reviewTimestampLabel.text = reviews.relativeTimeDescription
        reviewTextLabel.text = reviews.text
        
        guard let rating = reviews.rating,
            let profilePhotoUrl = reviews.profilePhotoUrl else { return }
        let reviewRating = Double(rating).roundToClosestHalf()
        
        DispatchQueue.main.async {
            self.reviewRatingImageView.image = StarRatingHelper.returnStarFrom(rating: reviewRating)
            self.reviewerProfileImageView.kf.indicatorType = .activity
            self.reviewerProfileImageView.kf.setImage(with: URL(string: profilePhotoUrl), options: [.transition(ImageTransition.fade(0.2))])
        }
    }
}
