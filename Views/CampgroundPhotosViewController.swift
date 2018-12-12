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
    var photoReferences: [Photos]?
    var images: [UIImage] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.tableFooterView = UIView()
        photosTableView.rowHeight = 300
        
        fetchPhoto()
    }
    
    func fetchPhoto() {
        guard let photoReferences = photoReferences else {
            return
        }
        
        photoReferences.forEach { (photoRef) in
            let referenceString = photoRef.photoReference ?? ""
            GoogleDetailController.fetchPlacePhotoWith(photoReference: referenceString, completion: { (image) in
                if let image = image {
                    self.images.append(image)
                }
                
                self.reloadTableView()
            })
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.photosTableView.delegate = self
            self.photosTableView.dataSource = self
            self.photosTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PhotoDetailViewController.segueIdentifier {
            if let indexPath = self.photosTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as? PhotoDetailViewController else {
                    return
                }
                
                let selectedPhoto = images[indexPath.row]
                detailVC.photo = selectedPhoto
            }
        }
    }
}

extension CampgroundPhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.identifier, for: indexPath) as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        
        let photo = images[indexPath.row]
        cell.photos = photo
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photosTableView.deselectRow(at: indexPath, animated: true)
    }
}
