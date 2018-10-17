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
import GoogleMobileAds

class HikingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hikingSearchBar: UISearchBar!
    @IBOutlet weak var hikingTableView: UITableView!
    
    // MARK: - Properties
    let geoCoder = CLGeocoder()
    
    var trails: [Trails]?
    
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hikingDetail" {
            if let indexPath = self.hikingTableView.indexPathForSelectedRow {
                guard let detailVC = segue.destination as? HikingDetailViewController,
                    let trails = trails else { return }
                
                let selectedTrail = trails[indexPath.row]
                
                detailVC.trails = selectedTrail
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
        
        geoCoder.geocodeAddressString(searchText) { (placemarks, error) in
            guard let placemarks = placemarks,
                let location = placemarks.first?.location?.coordinate else { return }
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            HikingTrailController.fetchHikingTrailsNear(latitude: "\(latitude)", longitude: "\(longitude)") { (trails) in
                if let trails = trails {
                    self.trails = trails
                }
                
                self.reloadTableView()
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
