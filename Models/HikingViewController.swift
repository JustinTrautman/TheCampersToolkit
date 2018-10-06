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
import SwiftyJSON
import GoogleMaps
import GoogleMobileAds

class HikingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hikingSearchBar: UISearchBar!
    @IBOutlet weak var hikingTableView: UITableView!
    
    // MARK: - Properties
    static let shared = HikingViewController()
    var trails: [Trails]?
    
    var coordinates: [Results]?
    
    lazy var adBannerView: GADBannerView = {
        
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Constants.bannerAdUnitID
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hikingSearchBar.delegate = self
        hikingTableView.delegate = self
        hikingTableView.dataSource = self
        
        hikingTableView.tableFooterView = UIView()
        
        reloadTableView()
        
        // Load Ad Banner
        adBannerView.load(GADRequest())
    }
    
    //     MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hikingDetail" {
            if let indexPath = self.hikingTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as? HikingDetailViewController else { return }
                
                guard let trails = trails else { return }
                
                let trail = trails[indexPath.row]
                
                detailVC.trails = trail
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.hikingTableView.reloadData()
        }
    }
}

// MARK: - Google adView Protocol Methods
extension HikingViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("Ad banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("Failed to receive ads. Exiting with error \(error) \(error.localizedDescription)")
    }
}

extension HikingViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hikingSearchBar.resignFirstResponder()
        guard let searchText = hikingSearchBar.text else { return }
        
        GoogleGeocodingController.getCoordinatesFrom(adress: searchText) { (coordinates) in
            
            if let coordinates = coordinates {
                if let location = coordinates[0].geometry?.location {
                    self.coordinates = coordinates
                    
                    guard let latitude = location.lat,
                        let longitude = location.lng else { return }
                    
                    HikingTrailController.fetchHikingTrailsNear(latitude: "\(latitude)", longitude: "\(longitude)") { (trails) in
                        if let trails = trails {
                            self.trails = trails
                        }
                        self.reloadTableView()
                    }
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hikingSearchBar.resignFirstResponder()
    }
}

extension HikingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return adBannerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return adBannerView.frame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trails = trails else { return 0 }
        
        return trails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "hikingCell", for: indexPath) as? HikingTableViewCell else { return UITableViewCell() }
        
        guard let unwrappedTrails = trails else { return UITableViewCell() }
        
        let index = unwrappedTrails[indexPath.row]
        cell.trails = index
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hikingTableView.deselectRow(at: indexPath, animated: true)
    }
}
