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
import Kingfisher
import CoreLocation

class HikingDetailViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var trailImageView: UIImageView!
    @IBOutlet weak private var trailNameLabel: UILabel!
    @IBOutlet weak private var ratingImageView: UIImageView!
    @IBOutlet weak private var voteCountLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var lengthLabel: UILabel!
    @IBOutlet weak private var ascentLabel: UILabel!
    @IBOutlet weak private var descentLabel: UILabel!
    @IBOutlet weak private var highestPointLabel: UILabel!
    @IBOutlet weak private var lowestPointLabel: UILabel!
    @IBOutlet weak private var conditionLabel: UILabel!
    @IBOutlet weak private var directionsButton: UIButton!
    
    // MARK: Properties
    var trails: Trails?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        directionsButton.applyGreenTheme(buttonTitle: "Take me to this trail")
    }
    
    // MARK: View Updaters and Handlers
    func updateViews() {
        guard let trail = trails else {
            return
        }
        
        let trailPhotoUrl = URL(string: trails?.imgMedium ?? "")
        let defaultImage = UIImage(named: "hikingDefault")
        let transition = ImageTransition.fade(0.2)
        
        let trailName = trail.name ?? "Unknown Trail"
        let rating = trail.stars ?? 0
        let voteCount = trail.starVotes ?? 0
        let trailDescription = trail.summary ?? "No description provided."
        let lengthValue = trail.length ?? 0
        let length = lengthValue == 0 ? "unknown" : String(describing: lengthValue)
        let ascentValue = trail.ascent ?? 0
        let ascent = ascentValue == 0 ? "unknown" : String(describing: ascentValue)
        let descentValue = trail.descent ?? 0
        let descent = descentValue == 0 ? "unknown" : String(describing: descentValue)
        let highPointValue = trail.high ?? 0
        let highestPoint = highPointValue == 0 ? "unknown" : String(describing: highPointValue)
        let lowPointValue = trail.low ?? 0
        let lowestPoint = lowPointValue == 0 ? "unknown" : String(describing: lowPointValue)
        let trailCondition = trail.conditionDetails ?? "No condition report."
        let dateFromServer = trail.conditionDate?.formatIsoDate ?? "January 01, 1970"
        let dateLastUpdated = dateFromServer == "January 01, 1970" ? "never" : dateFromServer
        // The api returns January 01, 1970 if it has never been updated. If January 01, 1970 is returned, just say it has never been updated.
        
        DispatchQueue.main.async {
            self.trailImageView.kf.setImage(with: trailPhotoUrl, placeholder: defaultImage, options: [.transition(transition)])
            self.trailNameLabel.text = trailName
            self.ratingImageView.image = StarRatingHelper.returnStarFrom(rating: rating.roundToClosestHalf())
            self.voteCountLabel.text = "(\(voteCount) votes)"
            self.descriptionLabel.text = trailDescription
            self.lengthLabel.text = "\(length) miles"
            self.ascentLabel.text = "\(ascent) ft."
            self.descentLabel.text = "\(descent) ft."
            self.highestPointLabel.text = "\(highestPoint) ft."
            self.lowestPointLabel.text = "\(lowestPoint) ft."
            self.conditionLabel.text = "\(trailCondition). Last updated: \(dateLastUpdated)."
            
            self.updateViewConstraints()
        }
    }
    
    // MARK: Actions
    @IBAction func directionsButtonTapped(_ sender: Any) {
        guard let latitude = trails?.latitude,
            let longitude = trails?.longitude,
            let trailName = trails?.name else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        OpenUrlHelper.openNavigationApp(withAddress: nil, orCoordinates: coordinates, mapItemName: trailName)
    }
}

