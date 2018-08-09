/*
 ----------------------------------------------------------------------------------------
 
 PhotoDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/29/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class PhotoDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var photoDetailImageView: UIImageView!
    
    // MARK: - Properties
    var photo: Photos?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let photoReference = photo?.photoReference else { return }
        
        GoogleDetailController.fetchCampgroundPhotosWith(photoReference: photoReference) { (photo) in
            if let photo = photo {
                DispatchQueue.main.async {
                    self.photoDetailImageView.image = photo
                }
            }
        }
    }
}
