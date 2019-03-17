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
import Lottie

class WeatherViewController: UIViewController { // TODO: Refactor this class
    
    // MARK: - Outlets
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var weatherImageView: UIImageView!
    @IBOutlet weak private var weatherDescriptionLabel: UILabel!
    @IBOutlet weak private var thermometerImageView: UIImageView!
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var highTempLabel: UILabel!
    @IBOutlet weak private var lowTempLabel: UILabel!
    @IBOutlet weak private var humidityLabel: UILabel!
    @IBOutlet weak private var windLabel: UILabel!
    @IBOutlet weak private var windSpeedImageView: UIImageView!
    @IBOutlet weak private var sunriseLabel: UILabel!
    @IBOutlet weak private var sunsetLabel: UILabel!
    @IBOutlet weak private var cloudStatusImageView: UIImageView!
    @IBOutlet weak private var cloudStatusLabel: UILabel!
    @IBOutlet weak private var forecastCollectionView: UICollectionView!
    
    // MARK: - Properties
    var campgroundDetails: Result?
    var address: String?
    var currentWeatherData: CampgroundWeatherData?
    private var forecastedWeatherData: ForecastedWeatherData?
    private var selectedForecast: ForecastedWeatherData.Periods?
    
    private let geoCoder = CLGeocoder()
    private let animation = LOTAnimationView(name: "loadingWheel")
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        fetchForecastedWeather()
    }
    
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
                            
                            if let temp = weather.main?.temp?.roundToPlaces(places: 1) {
                                self.temperatureLabel.text = "\(temp) ℉"
                                
                                switch temp {
                                case _ where temp >= 90:
                                    self.thermometerImageView.image = UIImage(named: "hot")
                                case _ where temp <= 89:
                                    self.thermometerImageView.image = UIImage(named: "lowTemp")
                                case _ where temp <= 32:
                                    self.thermometerImageView.image = UIImage(named: "cold")
                                default:
                                    break
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
                                
                                switch wind {
                                case _ where wind <= 13:
                                    self.windSpeedImageView.image = UIImage(named: "windLow")
                                case _ where wind >= 14:
                                    self.windSpeedImageView.image = UIImage(named: "windMed")
                                case _ where wind >= 24:
                                    self.windSpeedImageView.image  = UIImage(named: "windHigh")
                                default:
                                    break
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
                                
                                switch clouds {
                                case _ where clouds < 10:
                                    self.cloudStatusLabel.text = "Light clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "lightClouds")
                                case _ where clouds < 50 && clouds > 10:
                                    self.cloudStatusLabel.text = "Mild clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "mildClouds")
                                case _ where clouds > 50:
                                    self.cloudStatusLabel.text = "Heavy clouds"
                                    self.cloudStatusImageView.image = UIImage(named: "heavyClouds")
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchForecastedWeather() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.showLoadingAnimation()
        }
        
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
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            self.animation.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    func showLoadingAnimation() {
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.clipsToBounds = true
        
        forecastCollectionView.addSubview(animation)
        animation.centerXAnchor.constraint(equalTo: forecastCollectionView.centerXAnchor).isActive = true
        animation.centerYAnchor.constraint(equalTo: forecastCollectionView.centerYAnchor).isActive = true
        animation.widthAnchor.constraint(equalToConstant: 300).isActive = true
        animation.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        animation.play()
        animation.loopAnimation = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ForecastDetailViewController.segueIdentifier {
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

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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

