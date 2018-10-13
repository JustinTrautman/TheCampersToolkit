/*
 ----------------------------------------------------------------------------------------
 
 ForecastCollectionViewCell.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 10/6/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var moreArrowImageView: UIImageView!
    
    var weeklyForecast: ForecastedWeatherData.Periods? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let forecastData = weeklyForecast else { return }
        
        dayOfWeekLabel.text = forecastData.name
        
        if let shortForecast = forecastData.shortForecast {
            forecastLabel.text = shortForecast
            
            if let temperature = forecastData.temperature {
                temperatureLabel.text = "\(temperature) ℉"
            }
        }
    }
}
