/*
 ----------------------------------------------------------------------------------------
 
 WeatherViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 TODO: Implement visibility on the weather screen. Convert meters to miles...
 TODO: Implement air pressure on the weather screen if room...
 TODO: Implement Sunrise and sunset times. Convert from Unix time to human time...
 TODO: Implement 5 day forcast...
 
 ----------------------------------------------------------------------------------------
 */


import UIKit
import GoogleMaps
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var thermometerImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var windSpeedImageView: UIImageView!
    @IBOutlet weak var windDegreesLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    // MARK: - Actions
    
    // MARK: - Properties
    var campgrounds: Result?
    var weather: CampgroundWeatherData?
    var address: String?

    var campgroundWeatherData: CampgroundWeatherData?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViews()
    }
    
    func updateViews() {
        
        if let campgroundsAddress = address {
            
            let address = campgroundsAddress
            let coordinatesFromAddress = getLocationFromAddress(address: address)
            
            print(address)
            print(coordinatesFromAddress)
            
            let latitude = "\(coordinatesFromAddress.latitude)"
            let longitude = "\(coordinatesFromAddress.longitude)"
            
            // Convert from UNIX time to human readable time
            let date = NSDate(timeIntervalSince1970: 1532607646)
            print(date)
            
            CurrentWeatherController.fetchCurrentWeatherOf(latitude: latitude, longitude: longitude) { (weather) in
                if let weather = weather {
                    self.campgroundWeatherData = weather
                    
                    DispatchQueue.main.async {
                        
                        self.addressLabel.text = address
                        
                        if let weather = weather.weather {
                            
                            let weatherIndex = weather[0]
                            if let shortWeatherDescription = weatherIndex.main {
                                if let longWeatherDescription = weatherIndex.description {
                                    
                                    self.weatherDescriptionLabel.text = "\(shortWeatherDescription); \(longWeatherDescription)"
                                    
                                    if shortWeatherDescription == "Clear" {
                                        self.weatherImageView.image = UIImage(named: "sunny")
                                    }
                                    
                                    if shortWeatherDescription == "Clouds" {
                                        self.weatherImageView.image = UIImage(named: "cloudy")
                                    }
                                    
                                    if shortWeatherDescription == "Rain" {
                                        self.weatherImageView.image = UIImage(named: "rain")
                                    }
                                    
                                    if longWeatherDescription == "thunderstorm" {
                                        self.weatherImageView.image = UIImage(named: "thunder")
                                    }
                                    
                                    if longWeatherDescription == "thunderstorm with heavy rain" {
                                        self.weatherImageView.image = UIImage(named: "thunderWithRain")
                                    }
                                    
                                    if shortWeatherDescription == "Drizzle" {
                                        self.weatherImageView.image = UIImage(named: "lightRain")
                                    }
                                    
                                    if shortWeatherDescription == "snow" {
                                        self.weatherImageView.image = UIImage(named: "snow")
                                    }
                                }
                            }
                        }
                        
                        if let temp = weather.main?.temp?.roundToClosestHalf() {
                            self.temperatureLabel.text = "\(temp) ℉"
                            
                            if temp >= 90.0 {
                                self.thermometerImageView.image = UIImage(named: "hot")
                            }
                            
                            if temp <= 60.0 {
                                self.thermometerImageView.image = UIImage(named: "lowTemp")
                            }
                            
                            if temp <= 32.0 {
                                self.thermometerImageView.image = UIImage(named: "cold")
                                
                            }
                        }
                        
                        if let highTemp = weather.main?.tempMax {
                            self.highTempLabel.text = "\(highTemp) ℉"
                        }
                        
                        if let lowTemp = weather.main?.tempMin {
                            self.lowTempLabel.text = "\(lowTemp) ℉"
                        }
                        
                        if let humidity = weather.main?.humidity {
                            self.humidityLabel.text = "\(humidity) %"
                        }
                        
                        if let wind = weather.wind?.speed {
                            self.windLabel.text = "\(wind) mph"
                            
                            if wind <= 13 {
                                self.windSpeedImageView.image = UIImage(named: "windLow")
                            }
                            
                            if wind >= 13 {
                                self.windSpeedImageView.image = UIImage(named: "windMed")
                            }
                            
                            if wind >= 24 {
                                self.windSpeedImageView.image  = UIImage(named: "windHigh")
                            }
                        }
                        
                        if let windDirection = weather.wind?.windDirection {
                            
                            if windDirection == nil {
                                self.windDegreesLabel.text = ""
                            }
                            
                            if windDirection <= 22.5 || windDirection >= 337.5 {
                                self.windDegreesLabel.text = "°N"
                            }
                            
                            if windDirection <= 90 {
                                self.windDegreesLabel.text = "°E"
                            }
                            
                            
                            if windDirection <= 270 {
                                self.windDegreesLabel.text = "°W"
                            }
                        }
                    }
                }
            }
        }
    }
        
    public func getLocationFromAddress(address : String) -> CLLocationCoordinate2D {
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        do {
            
            let url = String(format: "https://maps.googleapis.com/maps/api/geocode/json?&sensor=false&address=%@", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
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
