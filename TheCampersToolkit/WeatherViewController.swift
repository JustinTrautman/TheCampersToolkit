/*
 ----------------------------------------------------------------------------------------
 
 WeatherViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/22/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ✔ TODO: Implement Sunrise and sunset times. Convert from Unix time to human time...
 ✔ TODO: Implement weekly forcast...
 ✔ TODO: Replace Google Geocoder with CLGeocoder
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMaps
import GoogleMobileAds

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
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var cloudStatusImageView: UIImageView!
    @IBOutlet weak var cloudStatusLabel: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    // MARK: - Properties
    var campgrounds: Result?
    var weather: CampgroundWeatherData?
    var address: String?
    var currentWeatherData: CampgroundWeatherData?
    var forecastedWeatherData: ForecastedWeatherData?
    var selectedForecast: ForecastedWeatherData.Periods?
    
    let geoCoder = CLGeocoder()
    
    // Banner Ad Setup
    var bannerView: GADBannerView!
    
    lazy var adBannerView: GADBannerView = {
        
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Constants.bannerAdUnitID
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Ad Banner
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        
        // Load Ad Banner
        adBannerView.load(GADRequest())
        
        updateViews()
        fetchForecastedWeather()
    }
    
    // TODO: - Keep this pyramid of if lets from becoming the worlds 8th wonder.
    // TODO: - Move declarations off main thread
    func updateViews() {
        if let campgroundsAddress = address {
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(campgroundsAddress) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
                
                let latitude = location.latitude
                let longitude = location.longitude
                
                CurrentWeatherController.fetchCurrentWeatherWith(latitude: "\(latitude)", longitude: "\(longitude)") { (weather) in
                    if let weather = weather {
                        self.currentWeatherData = weather
                        
                        DispatchQueue.main.async {
                            self.addressLabel.text = self.address
                            
                            if let weather = weather.weather {
                                let weatherIndex = weather[0]
                                
                                guard let shortWeatherDescription = weatherIndex.main,
                                    let longWeatherDescription = weatherIndex.description,
                                    let weatherType = WeatherType(rawValue: shortWeatherDescription) else { return }
                                
                                self.weatherDescriptionLabel.text = "\(shortWeatherDescription); \(longWeatherDescription)"
                                
                                switch weatherType {
                                case .clear:
                                    self.weatherImageView.image = UIImage(named: "sunny")
                                case .clouds:
                                    self.weatherImageView.image = UIImage(named: "cloudy")
                                case .rain:
                                    self.weatherImageView.image = UIImage(named: "rain")
                                case .thunderstorm:
                                    self.weatherImageView.image = UIImage(named: "thunder")
                                case .drizzle:
                                    self.weatherImageView.image = UIImage(named: "lightRain")
                                case .snow:
                                    self.weatherImageView.image = UIImage(named: "snow")
                                case .haze:
                                    self.weatherImageView.image = UIImage(named: "haze")
                                case .smoke:
                                    self.weatherImageView.image = UIImage(named: "smoke")
                                case .fog:
                                    self.weatherImageView.image = UIImage(named: "fog")
                                case .mist:
                                    self.weatherImageView.image = UIImage(named: "mist")
                                }
                            }
                            
                            // TODO: - Put temperature cases on switch statement
                            if let temp = weather.main?.temp?.roundToPlaces(places: 1) {
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
                                self.highTempLabel.text = "\(highTemp.roundToPlaces(places: 1)) ℉"
                            }
                            
                            if let lowTemp = weather.main?.tempMin {
                                self.lowTempLabel.text = "\(lowTemp.roundToPlaces(places: 1)) ℉"
                            }
                            
                            if let humidity = weather.main?.humidity {
                                self.humidityLabel.text = "\(humidity) % humidity"
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
                            
                            // Sunset and Sunrise
                            if let sunrise = weather.sys?.sunrise {
                                
                                // Converts from UNIX time to human readable time
                                let date = NSDate(timeIntervalSince1970: Double(sunrise))
                                let dateFormatter = DateFormatter()
                                
                                dateFormatter.dateFormat = "hh:mm a"
                                
                                let dateString = dateFormatter.string(from: date as Date)
                                
                                self.sunriseLabel.text = dateString
                            }
                            
                            if let sunset = weather.sys?.sunset {
                                
                                // Convert from UNIX time to human readable time
                                let date = NSDate(timeIntervalSince1970: Double(sunset))
                                let dateFormatter = DateFormatter()
                                
                                dateFormatter.dateFormat = "hh:mm a"
                                
                                let dateString = dateFormatter.string(from: date as Date)
                                
                                self.sunsetLabel.text = dateString
                            }
                            
                            if let clouds = weather.clouds?.all {
                                if clouds < 10 {
                                    self.cloudStatusLabel.text = "Light clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "lightClouds")
                                }
                                
                                if clouds < 50 && clouds > 10 {
                                    self.cloudStatusLabel.text = "Mild clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "mildClouds")
                                }
                                
                                if clouds > 50 {
                                    self.cloudStatusLabel.text = "Heavy clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "heavyClouds")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchForecastedWeather() {
        if let campgroundsAddress = address {
            geoCoder.geocodeAddressString(campgroundsAddress) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
                
                let latitude = location.latitude
                let longitude = location.longitude
                
                ForeCastedWeaterController.fetchForecastedWeatherAt(latitude: "\(latitude)", longitude: "\(longitude)") { (forecast) in
                    if let forecast = forecast {
                        self.forecastedWeatherData = forecast
                        
                        DispatchQueue.main.async {
                            self.forecastCollectionView.delegate = self
                            self.forecastCollectionView.dataSource = self
                            self.forecastCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForecastDetailVC" {
            guard let destinationVC = segue.destination as? ForecastDetailViewController,
                let weatherData = forecastedWeatherData,
                let weatherProperties = weatherData.properties,
                let periods = weatherProperties.periods else { return }
            
            if let sender = sender as? ForecastCollectionViewCell {
                guard let indexPath = forecastCollectionView.indexPath(for: sender) else { return }
                let selectedForecast = periods[indexPath.row]
                
                destinationVC.forecastedWeatherData = selectedForecast
                destinationVC.locationElevation = forecastedWeatherData
            }
        }
    }
}

extension WeatherViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let weatherData = forecastedWeatherData,
            let weatherProperties = weatherData.properties,
            let periods = weatherProperties.periods else { return 0 }
        
        return periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekDayCell", for: indexPath) as? ForecastCollectionViewCell else { return UICollectionViewCell() }
        
        guard let weatherData = forecastedWeatherData,
            let weatherProperties = weatherData.properties,
            let periods = weatherProperties.periods else { return UICollectionViewCell() }
        
        let weekDays = periods[indexPath.row]
        
        cell.weeklyForecast = weekDays
        
        // Configure day/night theme on individual cells
        if weekDays.isDaytime == false {
            cell.weatherImageView.image = UIImage(named: "moon")
            cell.backgroundColor = .black
            cell.dayOfWeekLabel.textColor = .white
            cell.temperatureLabel.textColor = .white
            cell.forecastLabel.textColor = .white
            cell.moreArrowImageView.image = UIImage(named: "whiteMoreArrow")
            
            return cell
        } else {
            cell.weatherImageView.image = UIImage(named: "sunny")
            cell.backgroundColor = .white
            cell.dayOfWeekLabel.textColor = .black
            cell.temperatureLabel.textColor = .black
            cell.forecastLabel.textColor = .black
            cell.moreArrowImageView.image = UIImage(named: "blackMoreArrow")
            
            return cell
        }
    }
}

extension WeatherViewController : GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("Ad banner loaded successfully")
        
        addBannerViewToView(bannerView)
        
        // Reposition the banner ad to create a slide down effect
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            bannerView.alpha = 1
        })
    }
}
