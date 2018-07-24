//
//  CampgroundPhotosViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/22/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

/*
 ----------------------------------------------------------------------------------------
 
 CampgroundPhotosViewController.swift
 TheCampersToolkit

 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class CampgroundPhotosViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var photoStringLabel: UILabel!
    
    // MARK: - Properties
    var photos: Photos? {
        didSet {
            updateViews()
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateViews() {
        guard let photos = photos else { return }
        
        photoStringLabel.text = photos.photoReference
    }
}
