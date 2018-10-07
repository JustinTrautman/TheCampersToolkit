//
//  ForecastCollectionViewCell.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 10/6/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    // MARK: - Properties
    var forecastWeatherData: ForecastedWeatherData? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let forecastedWeatherData = forecastWeatherData,
        let dayOfTheWeek = Date().dayOfWeek() else { return }
        
        dayOfWeekLabel.text = dayOfTheWeek
    }
}
