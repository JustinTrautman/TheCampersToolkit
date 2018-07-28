//
//  PhotoTableViewCell.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/27/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var subview1: UIImageView!
    @IBOutlet weak var subview2: UIImageView!
    
    // MARK: - Properties
    var photos: Photos? {
        didSet {
            updateViews()
        }
    }
    
    var campgrounds: Result? {
        didSet {
        updateViews()
        }
    }
    
    func updateViews() {
        
        guard let photoArray = photos?.photoReference else { return }
        GoogleDetailController.fetchCampgroundPhotosWith(photoReference: photoArray) { (photos) in
            if let photos = photos {
                DispatchQueue.main.async {
//                    self.headerImageView.image = UIImage(photos)
                }
            }
        }
        
    }
}
