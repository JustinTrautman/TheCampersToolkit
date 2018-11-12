/*
 ----------------------------------------------------------------------------------------
 
 CampgrounHoursViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/27/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class CampgroundHoursViewController: UIViewController {
    
    // MARK: - Outlets!
    @IBOutlet weak var todaysHoursLabel: UILabel!
    @IBOutlet weak var mondaysHoursLabel: UILabel!
    @IBOutlet weak var tuesdaysHoursLabel: UILabel!
    @IBOutlet weak var wednesdaysHoursLabel: UILabel!
    @IBOutlet weak var thursdaysHoursLabel: UILabel!
    @IBOutlet weak var fridaysHoursLabel: UILabel!
    @IBOutlet weak var saturdaysHoursLabel: UILabel!
    @IBOutlet weak var sundaysHoursLabel: UILabel!
    
    // MARK: - Properties
    var hours: Result?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    func updateView() {
        guard let hours = hours,
            let weekdays = hours.openingHours?.weekdayText,
            let dayOfTheWeek = Date().dayOfWeek(),
            let dayCases = DayOfTheWeek(rawValue: dayOfTheWeek) else { return }
        
        let mondaysHours = hourFormatter(hoursText: weekdays[0])
        let tuesdaysHours = hourFormatter(hoursText: weekdays[1])
        let wednesdaysHours = hourFormatter(hoursText: weekdays[2])
        let thursdaysHours = hourFormatter(hoursText: weekdays[3])
        let fridaysHours = hourFormatter(hoursText: weekdays[4])
        let saturdaysHours = hourFormatter(hoursText: weekdays[5])
        let sundaysHours = hourFormatter(hoursText: weekdays[6])
        
        switch dayCases {
        case .monday:
            todaysHoursLabel.text = mondaysHours
        case .tuesday:
            todaysHoursLabel.text = tuesdaysHours
        case .wednesday:
            todaysHoursLabel.text = wednesdaysHours
        case .thursday:
            todaysHoursLabel.text = thursdaysHours
        case .friday:
            todaysHoursLabel.text = fridaysHours
        case .saturday:
            todaysHoursLabel.text = saturdaysHours
        case .sunday:
            todaysHoursLabel.text = sundaysHours
        }
        
        mondaysHoursLabel.text = mondaysHours
        tuesdaysHoursLabel.text = tuesdaysHours
        wednesdaysHoursLabel.text = wednesdaysHours
        thursdaysHoursLabel.text = thursdaysHours
        fridaysHoursLabel.text = fridaysHours
        saturdaysHoursLabel.text = saturdaysHours
        sundaysHoursLabel.text = sundaysHours
    }
    
    func hourFormatter(hoursText: String) -> String {
        guard let hours = hoursText.range(of: ":")  else { return "" }
        let formattedHours = "\(hoursText[hours.upperBound...])"
        
        return formattedHours
    }
}
