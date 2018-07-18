//
//  CampgroundDetailViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/13/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class CampgroundDetailViewController: UIViewController {
    
    var campground: GooglePlace?
    
    // MARK: - Outlets
    @IBOutlet weak var campgroundNameLabel: UILabel!
    @IBOutlet weak var campgroundImageView: UIImageView!
    
    var campgrounds: GooglePlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        guard let campgroundName = campground?.name,
              let campgroundImage = campground?.photo else { return }
        
        campgroundNameLabel.text = campgroundName
        campgroundImageView.image = campgroundImage
        
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
