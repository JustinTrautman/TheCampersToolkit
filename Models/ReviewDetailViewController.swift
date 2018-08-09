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

class ReviewDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var reviewerProfileImage: UIImageView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewTimestamp: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!

    // MARK: Properties
    var reviews: Reviews?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }

    func updateViews() {

        guard let reviews = reviews else { return }

        if let photoURL = reviews.profilePhotoUrl {
            GoogleDetailController.fetchReviewerProfilePhotoWith(photoUrl: photoURL) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.reviewerProfileImage.image = image
                    }
                }
            }
        }

        if let campgroundRating = reviews.rating {

            let roundedRating = Double(campgroundRating).roundToClosestHalf()

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

        reviewerNameLabel.text = reviews.authorName
        reviewTextView.text = reviews.text
        reviewTimestamp.text = reviews.relativeTimeDescription
    }
}
