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
import GoogleMobileAds

class ReviewDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var reviewerProfileImage: UIImageView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewTimestamp: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!

    // MARK: Properties
    var reviews: Reviews?
    
    // Banner Ad Setup
    var bannerView: GADBannerView!
    
    lazy var adBannerView: GADBannerView = {
        
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Constants.bannerAdUnitID
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Ad Banner
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        // Load Ad Banner
        adBannerView.load(GADRequest())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
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

extension ReviewDetailViewController : GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("Ad banner loaded successfully")
        
        addBannerViewToView(bannerView)
        
        // Reposition the banner ad to create a slide down effect
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            bannerView.alpha = 1
        })
    }
}
