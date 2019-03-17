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
import Kingfisher
import Lottie

class PhotosViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var photosTableView: UITableView!
    
    // MARK: - Properties
    var photoReferences: [Photos]?
    var images: [UIImage] = []
    private var photoCount = 0
    private let animation = LOTAnimationView(name: "loadingWheel")
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.tableFooterView = UIView()
        photosTableView.rowHeight = 300
        
        fetchPhoto()
    }
    
    func fetchPhoto() {
        guard let photoReferences = photoReferences else {
            return
        }
        
        photoCount = photoReferences.count
        
        photoReferences.forEach { (photoRef) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.showLoadingWheel()
            }
            
            let photoReference = photoRef.photoReference ?? "No reference"
            let photoUrl = String().googlePhotosUrl(photoRef: photoReference, maxWidth: 450)
            let downloader = ImageDownloader.default
            
            downloader.downloadImage(with: photoUrl, completionHandler: { (result) in
                switch result {
                case .success(let image):
                    self.images.append(image.image)
                    self.photoCount -= 1
                case .failure(let error):
                    print(error.localizedDescription)
                }
                if self.photoCount == 0 {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.reloadTableView()
                    self.animation.removeFromSuperview()
                }
            })
        }
    }
    
    func showLoadingWheel() {
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.clipsToBounds = true
        
        view.addSubview(animation)
        animation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animation.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animation.widthAnchor.constraint(equalToConstant: 300).isActive = true
        animation.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        animation.play()
        animation.loopAnimation = true
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.photosTableView.reloadData()
        }
    }
    
    // MARK: - Navigation
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

extension PhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? PhotoTableViewCell else {
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
