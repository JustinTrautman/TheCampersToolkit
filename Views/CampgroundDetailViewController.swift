//
//  CampgroundDetailViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/13/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class CampgroundDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var campgroundImageView: UIImageView!
    @IBOutlet weak var campgroundNameLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var campgroundRatingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var isOfficeOpenLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var campgroundAddressLabel: UILabel!
    @IBOutlet weak var campgroundWebsiteLabel: UILabel!
    
    
    // MARK: - Properties
    var campground: GooglePlace?
    var campgrounds: Result?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        
        // Some initial setup
        campgroundNameLabel.numberOfLines = 0
        campgroundAddressLabel.numberOfLines = 0
        
        // Updates from Google Place API
        guard let campgroundName = campground?.name,
        let campgroundImage = campground?.photo,
        let campgroundId = campground?.id else { return }
        
        navigationBar.topItem?.title = campgroundName
        campgroundNameLabel.text = campgroundName
        campgroundImageView.image = campgroundImage
        
        // Updates from Google Place Details API
        GoogleDetailController.fetchCampgroundDetailsWith(placeId: campgroundId) { (campground) in
            if let campground = campground {
                self.campgrounds = campground
                
                
                DispatchQueue.main.async {
                    
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
                    } else {
                        self.isOfficeOpenLabel.text = "Office closed now"
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
                        self.campgroundRatingImageView.image = UIImage(named: "0Star")
                    }
                    
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension Double{
    func roundToClosestHalf() -> Double{
        return Double(Int(self * 2)) / 2
    }
}
