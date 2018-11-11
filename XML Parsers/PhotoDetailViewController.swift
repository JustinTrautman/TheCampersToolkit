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

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailImageView: UIImageView!
    
    // MARK: - Properties
    var photo: Photos?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        updateViews()
    }
    
    func updateViews() {
        guard let photoReference = photo?.photoReference else { return }
        
        GoogleDetailController.fetchCampgroundPhotosWith(photoReference: photoReference) { (photo) in
            if let photo = photo {
                DispatchQueue.main.async {
                    self.detailImageView.image = photo
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return detailImageView
    }
}
