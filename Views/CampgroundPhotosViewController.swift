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
    @IBOutlet weak var photosTableView: UITableView!
    
    // MARK: - Properties
    var photos: Result?
    

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.tableFooterView = UIView()
        
        reloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
        self.photosTableView.reloadData()
        }
    }
}

extension CampgroundPhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let photos = photos?.photos else { return 0 }
        
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
        
        guard let photos = photos?.photos else { return UITableViewCell() }
        
        let indexPath = photos[indexPath.row]
        cell.photos = indexPath
        
        return cell
    }
}
