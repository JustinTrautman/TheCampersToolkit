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
    var photos: [Photos]?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.tableFooterView = UIView()
        photosTableView.rowHeight = 300
        
        reloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.photosTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoDetail" {
            if let indexPath = self.photosTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as? PhotoDetailViewController else { return }
                
                guard let photo = photos else { return }
                
                let selectedPhoto = photo[indexPath.row]
                
                detailVC.photo = selectedPhoto
            }
        }
    }
}

extension CampgroundPhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let unwrappedPhotos = GoogleDetailController.campgrounds?.photos else { return 0 }
        
        return unwrappedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }
        
        guard let unwrappedPhotos = GoogleDetailController.campgrounds?.photos else { return UITableViewCell() }
        
        let photo = unwrappedPhotos[indexPath.row]
        cell.photos = photo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photosTableView.deselectRow(at: indexPath, animated: true)
    }
}
