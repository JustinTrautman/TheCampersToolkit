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
import Cosmos

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
            let trailRating = trails?.stars,
            let trailPhotoUrl = trails?.imgMedium else { return }
        
        HikingTrailController.fetchTrailImageWith(photoURL: trailPhotoUrl) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.trailImageView.image = image
                }
            }
            
            if trailPhotoUrl == "" {
                self.trailImageView.image = UIImage(named: "hikingDefault")
            }
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
        
        switch roundedRating {
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
