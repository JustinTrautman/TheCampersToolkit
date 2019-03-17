/*
 ----------------------------------------------------------------------------------------
 
 HikingTableViewCell.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/23/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import Kingfisher

class HikingTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var trailImageView: UIImageView!
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var trailLocationLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var voteCounterLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    // MARK: - Properties
    var trails: Trails? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let voteCounter = trails?.starVotes,
            let trailRating = trails?.stars else { return }
        
        let trailPhotoUrl = URL(string: trails?.imgMedium ?? "")
        let defaultImage = UIImage(named: "hikingDefault")
        let transition = ImageTransition.fade(0.2)
        
        DispatchQueue.main.async {
            self.trailImageView.kf.indicatorType = .activity
            self.trailImageView.kf.setImage(with: trailPhotoUrl, placeholder: defaultImage, options: [.transition(transition)])
        }
        
        trailNameLabel.text = trails?.name
        trailLocationLabel.text = trails?.location
        
        if trails?.summary == "Needs Summary" {
            summaryLabel.text = "No Summary"
        } else {
            summaryLabel.text = trails?.summary
        }
        
        if voteCounter == 1 {
            voteCounterLabel.text = "\(voteCounter) vote"
        } else {
            voteCounterLabel.text = "\(voteCounter) votes"
        }
        
        let roundedRating = Double(trailRating).roundToClosestHalf()
        
        DispatchQueue.main.async {
            self.starRatingImageView.image = StarRatingHelper.returnStarFrom(rating: roundedRating)
        }
        
        guard let difficulty = trails?.difficulty else { return }
        
        if difficulty == "green" || difficulty == "greenBlue" {
            difficultyLabel.text = "Easy"
        }
        
        if difficulty == "blue" || difficulty == "blueBlack"{
            difficultyLabel.text = "Intermediate"
        }
        
        
        if difficulty == "black" || difficulty == "dBlack" {
            difficultyLabel.text = "Hard"
        }
        
        if difficulty == "" {
            difficultyLabel.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trailImageView.image = nil
    }
}
