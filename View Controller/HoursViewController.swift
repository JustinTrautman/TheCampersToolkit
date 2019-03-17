/*
 ----------------------------------------------------------------------------------------
 
 HoursViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/27/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class HoursViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak private var todaysHoursLabel: UILabel!
    @IBOutlet weak private var mondaysHoursLabel: UILabel!
    @IBOutlet weak private var tuesdaysHoursLabel: UILabel!
    @IBOutlet weak private var wednesdaysHoursLabel: UILabel!
    @IBOutlet weak private var thursdaysHoursLabel: UILabel!
    @IBOutlet weak private var fridaysHoursLabel: UILabel!
    @IBOutlet weak private var saturdaysHoursLabel: UILabel!
    @IBOutlet weak private var sundaysHoursLabel: UILabel!
    
    // MARK: - Properties
    var hours: OpeningHours?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    func updateView() {
        guard let hours = hours,
            let weekdays = hours.weekdayText,
            let dayOfTheWeek = Date().dayOfWeek(),
            let dayCases = DayOfTheWeek(rawValue: dayOfTheWeek) else { return }
        
        guard weekdays.count >= 7 else {
            // Not enough data to show weekly hours
            return
        }
        
        let mondaysHours = hourFormatter(hoursText: weekdays[0])
        let tuesdaysHours = hourFormatter(hoursText: weekdays[1])
        let wednesdaysHours = hourFormatter(hoursText: weekdays[2])
        let thursdaysHours = hourFormatter(hoursText: weekdays[3])
        let fridaysHours = hourFormatter(hoursText: weekdays[4])
        let saturdaysHours = hourFormatter(hoursText: weekdays[5])
        let sundaysHours = hourFormatter(hoursText: weekdays[6])
        
        DispatchQueue.main.async {
            switch dayCases {
            case .monday:
                self.mondaysHoursLabel.text = mondaysHours
            case .tuesday:
                self.todaysHoursLabel.text = tuesdaysHours
            case .wednesday:
                self.todaysHoursLabel.text = wednesdaysHours
            case .thursday:
                self.todaysHoursLabel.text = thursdaysHours
            case .friday:
                self.todaysHoursLabel.text = fridaysHours
            case .saturday:
                self.saturdaysHoursLabel.text = saturdaysHours
            case .sunday:
                self.todaysHoursLabel.text = sundaysHours
            }
            
            self.mondaysHoursLabel.text = mondaysHours
            self.tuesdaysHoursLabel.text = tuesdaysHours
            self.wednesdaysHoursLabel.text = wednesdaysHours
            self.thursdaysHoursLabel.text = thursdaysHours
            self.fridaysHoursLabel.text = fridaysHours
            self.saturdaysHoursLabel.text = saturdaysHours
            self.sundaysHoursLabel.text = sundaysHours
        }
    }
    
    // TODO: Replace with new helper function
    func hourFormatter(hoursText: String) -> String {
        guard let hours = hoursText.range(of: ":")  else { return "" }
        let formattedHours = "\(hoursText[hours.upperBound...])"
        
        return formattedHours
    }
}
