//
//  CampgroundReviewCell.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/22/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class CampgroundReviewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var reviewerProfileImageView: UIImageView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var reviewRatingImageView: UIImageView!
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
            reviewRatingImageView.image = UIImage(named: "1Star")
        case 1.5:
            reviewRatingImageView.image = UIImage(named: "1.5Stars")
        case 2:
            reviewRatingImageView.image = UIImage(named: "2Stars")
        case 2.5:
            reviewRatingImageView.image = UIImage(named: "2.5Stars")
        case 3:
            reviewRatingImageView.image = UIImage(named: "3Stars")
        case 3.5:
            reviewRatingImageView.image = UIImage(named: "3.5Stars")
        case 4:
            reviewRatingImageView.image = UIImage(named: "4Stars")
        case 4.5:
            reviewRatingImageView.image = UIImage(named: "4.5Stars")
        case 5:
            reviewRatingImageView.image = UIImage(named: "5Stars")
        default:
            reviewRatingImageView.image = UIImage(named: "0Stars")
        }
        
        GoogleDetailController.fetchReviewerProfilePhotoWith(photoUrl: profilePhotoUrl) { (image) in
            guard let fetchedImage = image else { return }
                
                DispatchQueue.main.async {
                    self.reviewerProfileImageView.image = fetchedImage
            }
        }
    }
}
