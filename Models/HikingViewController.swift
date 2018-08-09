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

class HikingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hikingSearchBar: UISearchBar!
    @IBOutlet weak var hikingTableView: UITableView!
    
    // MARK: - Properties
    static let shared = HikingViewController()
    var trails: [Trails]?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hikingSearchBar.delegate = self
        hikingTableView.delegate = self
        hikingTableView.dataSource = self
        
        hikingTableView.tableFooterView = UIView()

        reloadTableView()
    }
    
    public func getLocationFromAddress(address : String) -> CLLocationCoordinate2D {
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        do {
            
            let url = String(format: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=%@&key=\(Constants.googleApiKey)", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
            let result = try Data(contentsOf: URL(string: url)!)
            let json = try JSON(data: result)
            
            lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
            lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
            
            print(lat)
            print(lon)
            
        } catch let error {
            print(error)
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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

extension HikingViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        hikingSearchBar.resignFirstResponder()
        guard let searchText = hikingSearchBar.text else { return }
        
        let address = getLocationFromAddress(address: searchText)
        let latitude = "\(address.latitude)"
        let longitude = "\(address.longitude)"
        
        HikingTrailController.fetchHikingTrailsNear(latitude: latitude, longitude: longitude) { (trails) in
            if let trails = trails {
                self.trails = trails
            }
            self.reloadTableView()
        }
    }
}

extension HikingViewController : UITableViewDelegate, UITableViewDataSource {
    
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

