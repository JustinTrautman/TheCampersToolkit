/*
 ----------------------------------------------------------------------------------------
 
 PhotoTableViewCell.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/27/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */


import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    static let shared = PhotoTableViewCell()
    
    // MARK: - Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    
    // MARK: - Properties
    var photos: Photos? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        guard let unwrappedPhotos = self.photos else { return }
        
        guard let photoReference = unwrappedPhotos.photoReference else { return }
        
        GoogleDetailController.fetchCampgroundPhotosWith(photoReference: "\(photoReference)", completion: { (photo) in
            if let photo = photo {
                DispatchQueue.main.async {
                    self.headerImageView.image = photo
                }
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        headerImageView.image = nil
    }
}
