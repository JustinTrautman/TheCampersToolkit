/*
 ----------------------------------------------------------------------------------------
 
 WeatherDetailViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 10/6/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import GoogleMobileAds

class ForecastDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayTypeImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    // MARK: - Properties
    var forecastedWeatherData: ForecastedWeatherData.Periods?
    var locationElevation: ForecastedWeatherData?
    
    // Banner Ad Setup
    var bannerView: GADBannerView!
    
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
        
        updateViews()
        
        // Setup Ad Banner
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        // Load Ad Banner
        adBannerView.load(GADRequest())
    }
    
    func updateViews() {
        guard let forecastedWeatherData = forecastedWeatherData else { return }
        
        guard let name = forecastedWeatherData.name,
            let temperature = forecastedWeatherData.temperature,
            let windSpeed = forecastedWeatherData.windSpeed,
            let windDirection = forecastedWeatherData.windDirection,
            let weatherDescription = forecastedWeatherData.detailedForecast,
            let forecastProperties = locationElevation?.properties,
            let elevation = forecastProperties.elevation?.value else { return }
        
        if let isDay = forecastedWeatherData.isDaytime {
            if isDay == false {
                setNightTheme()
            } else {
                dayTypeImageView.image = UIImage(named: "sunnyBig")
            }
        }
        
        dayNameLabel.text = name
        temperatureLabel.text = "\(temperature) ℉"
        windSpeedLabel.text = "The expected wind speed is \(windSpeed) \(windDirection)"
        weatherDescriptionLabel.text = weatherDescription
        
        let elevationInFeet = elevation * 3.2808
        
        elevationLabel.text = "Elevation: \(elevationInFeet.roundToClosestHalf()) ft."
    }
    
    func setNightTheme() {
        parentView.backgroundColor = .black
        navigationBar.barStyle = UIBarStyle.black
        dayNameLabel.textColor = .white
        dayTypeImageView.image = UIImage(named: "moonBig")
        temperatureLabel.textColor = .white
        elevationLabel.textColor = .white
        windSpeedLabel.textColor = .white
        weatherDescriptionLabel.textColor = .white
    }
    
    // TODO: Separate this function into helper file
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide, // TODO: Update deprecated code
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
}

extension ForecastDetailViewController : GADBannerViewDelegate {
    
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

