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
        
    // MARK: - Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    
    // MARK: - Properties
    var photos: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let unwrappedPhotos = self.photos else { return }
        
        DispatchQueue.main.async {
            self.headerImageView.image = unwrappedPhotos
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        headerImageView.image = nil
    }
}
