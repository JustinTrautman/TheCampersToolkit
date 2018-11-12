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
    var photo: UIImage?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        updateViews()
    }
    
    func updateViews() {
        guard let selectedPhoto = photo else { return }
        
        DispatchQueue.main.async {
            self.detailImageView.image = selectedPhoto
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    
        return detailImageView
    }
}
