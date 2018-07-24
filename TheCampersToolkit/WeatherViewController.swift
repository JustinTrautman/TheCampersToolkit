/*
 ----------------------------------------------------------------------------------------
 
 WeatherViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */


import UIKit
import GoogleMaps
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var campgroundAddressLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    // MARK: - Actions
    
    // MARK: - Properties
    var campgrounds: Result?
    var campgroundWeatherData: CampgroundWeatherData?
    
    var weather: Weather? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let address = campgrounds?.formattedAddress else { return }
        let coordinatesFromAddress = getLocationFromAddress(address: address)
        
        print(address)
        print(coordinatesFromAddress)
        
        CurrentWeatherController.fetchCurrentWeatherOf(latitude: "\(coordinatesFromAddress.latitude)", longitude: "\(coordinatesFromAddress.longitude)") { (weather) in
            if let weather = weather {
               self.campgroundWeatherData = weather
                
                DispatchQueue.main.async {
                    self.campgroundAddressLabel.text = address
                }
            }
        }
    }
    
    public func getLocationFromAddress(address : String) -> CLLocationCoordinate2D {
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        do {
            
            let url = String(format: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
            let result = try Data(contentsOf: URL(string: url)!)
            let json = try JSON(data: result)
            
            lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
            lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
            
        }
        catch let error{
            print(error)
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
