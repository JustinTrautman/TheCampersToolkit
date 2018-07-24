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
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    // MARK: Properties
    var review: Reviews? {
        didSet {
        updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateViews() {
        
        guard let review = review else { return }
        
        reviewerNameLabel.text = review.authorName
        reviewTextLabel.text = review.text
    }
}
