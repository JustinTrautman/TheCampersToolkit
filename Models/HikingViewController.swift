/*
 ----------------------------------------------------------------------------------------
 
 HikingViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/23/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import Lottie

class HikingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hikingSearchBar: UISearchBar!
    @IBOutlet weak private var hikingTableView: UITableView!
    
    // MARK: - Properties
    var trails: [Trails]?
    private let geoCoder = CLGeocoder()
    private let animation = LOTAnimationView(name: "loadingWheel")
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hikingSearchBar.delegate = self
        hikingTableView.delegate = self
        hikingTableView.dataSource = self
        hikingTableView.tableFooterView = UIView()
    }
    
    func showLoadingWheel() {
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.clipsToBounds = true
        
        DispatchQueue.main.async {
            self.hikingTableView.addSubview(self.animation)
            self.animation.centerXAnchor.constraint(equalTo: self.hikingTableView.centerXAnchor).isActive = true
            self.animation.centerYAnchor.constraint(equalTo: self.hikingTableView.centerYAnchor).isActive = true
            self.animation.widthAnchor.constraint(equalToConstant: 300).isActive = true
            self.animation.heightAnchor.constraint(equalToConstant: 300).isActive = true
            
            self.animation.play()
            self.animation.loopAnimation = true
            self.hikingTableView.isUserInteractionEnabled = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func hideLoadingWheel() {
        DispatchQueue.main.async {
            if self.animation.isDescendant(of: self.view) {
                self.animation.removeFromSuperview()
                self.hikingTableView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.hikingTableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == HikingDetailViewController.segueIdentifier {
            if let indexPath = self.hikingTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as? HikingDetailViewController,
                    let trails = trails else { return }
                
                let selectedTrail = trails[indexPath.row]
                detailVC.trails = selectedTrail
            }
        }
    }
}

extension HikingViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hikingSearchBar.resignFirstResponder()
        guard let searchText = hikingSearchBar.text else { return }
        
        showLoadingWheel()
        
        geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
            guard let placemarks = placemarks,
                let location = placemarks.first?.location?.coordinate else { return }
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            HikingTrailController.fetchHikingTrailsNear(latitude: "\(latitude)", longitude: "\(longitude)") { (trails) in
                if let trails = trails {
                    self.trails = trails
                    
                    self.hideLoadingWheel()
                    self.reloadTableView()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hikingSearchBar.resignFirstResponder()
    }
}

extension HikingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trails = trails else { hideLoadingWheel() ; return 0 }
        
        return trails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "hikingCell", for: indexPath) as? HikingTableViewCell else { return UITableViewCell() }
        
        guard let trails = trails else { return UITableViewCell() }
        
        let index = trails[indexPath.row]
        cell.trails = index
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hikingTableView.deselectRow(at: indexPath, animated: true)
    }
}
