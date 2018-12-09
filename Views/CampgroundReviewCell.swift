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
import Cosmos

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
        let reviewRating = Double(rating)
        
        switch reviewRating {
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
        
        GoogleDetailController.fetchReviewerProfilePhotoWith(photoUrl: profilePhotoUrl) { (image) in
            guard let fetchedImage = image else { return }
            
            DispatchQueue.main.async {
                self.reviewerProfileImageView.image = fetchedImage
            }
        }
    }
}
