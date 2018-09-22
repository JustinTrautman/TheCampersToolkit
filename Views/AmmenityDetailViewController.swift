//
//  AmmenityDetailViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 9/9/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class AmmenityDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var ammenityImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var openUntilLabel: UILabel!
    @IBOutlet weak var ammenityPhoneNumberButton: UIButton!
    @IBOutlet weak var ammenityRatingImageView: UIImageView!
    @IBOutlet weak var ammenityMapView: GMSMapView!
    @IBOutlet weak var takeMeHereButton: UIButton!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    
    // MARK: - Properties
    var ammenities: GooglePlace?
    var ammenitieDetails: Result?
    var ammenityImage: UIImage?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button will be disabled unless ammenity has a url from Google
        visitWebsiteButton.isEnabled = false
        
        updateViews()
        loadMiniMap()
    }
    
    // MARK: - Actions
    @IBAction func takeMeHereButtonTapped(_ sender: Any) {
        guard let address = ammenitieDetails?.formattedAddress,
            let title = ammenitieDetails?.name else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
        guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
        
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            UIApplication.shared.openURL(NSURL(string: "comgooglemaps://?daddr=\(location.latitude),\(location.longitude)&directionsmode=driving")! as URL)
        } else {
            print("Opening in Apple Maps")
            
            let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            mapItem.name = title
            mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
    @IBAction func phoneNumberButtonTapped(_ sender: Any) {
        guard let numberToCall = ammenityPhoneNumberButton.currentTitle?.replacingOccurrences(of: " ", with: "") else { return }
        if let phoneURL = URL(string: "telprompt://\(numberToCall)") {
        UIApplication.shared.canOpenURL(phoneURL)
            UIApplication.shared.open(phoneURL)
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: Any) {
        guard let url = ammenitieDetails?.website else { return }
        openWebsiteUrl(url: url)
    }
    
    func updateViews() {
        ammenityImageView.image = ammenityImage
        
        if let name = ammenitieDetails?.name {
            placeNameLabel.text = name
        }
        
        if let phoneNumber = ammenitieDetails?.formattedPhoneNumber {
            ammenityPhoneNumberButton.setTitle(phoneNumber, for: .normal)
            ammenityPhoneNumberButton.setTitleColor(.blue, for: .normal)
        }
        
        if let _ = ammenitieDetails?.website {
            visitWebsiteButton.isEnabled = true
            visitWebsiteButton.setTitleColor(.black, for: .normal)
        }
        
        guard let hoursOfOperation = ammenitieDetails?.openingHours else { return }
        
        let dayOfWeek = Date().dayOfWeek()!
        
        if let weeklyHours = hoursOfOperation.weekdayText {
            print("Showing hours for \(dayOfWeek)")
            
            if dayOfWeek == "Sunday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Monday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Tuesday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Wednesday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Thursday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Friday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
            
            if dayOfWeek == "Saturday" {
                let closingTime = returnClosingTime(forDay: dayOfWeek)
                openUntilLabel.text = "\(closingTime)"
            }
        }
        
        if let _ = ammenitieDetails?.rating {
            ammenityRatingImageView.image = UIImage(named: "2Stars")
        }
    }
    
    func openWebsiteUrl(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func returnClosingTime(forDay: String) -> String {
        guard let hoursOfOperation = ammenitieDetails?.openingHours?.weekdayText else { return "" }
        var hoursString: String!
        
        if forDay == "Monday" {
            hoursString = "\(hoursOfOperation[0])"
        }
        
        if forDay == "Tuesday" {
            hoursString = "\(hoursOfOperation[1])"
        }
        
        if forDay == "Wednesday" {
            hoursString = "\(hoursOfOperation[2])"
        }
        
        if forDay == "Thursday" {
            hoursString = "\(hoursOfOperation[3])"
        }
        
        if forDay == "Friday" {
            hoursString = "\(hoursOfOperation[4])"
        }
        
        if forDay == "Saturday" {
            hoursString = "\(hoursOfOperation[5])"
        }
        
        if forDay == "Sunday" {
            hoursString = "\(hoursOfOperation[6])"
        }
        
        if let hours = hoursString.range(of: "– ") {
            let closingHour = hoursString[hours.upperBound...]
            print("It closes at \(closingHour)")
            
            return "Open until \(closingHour)"
        }
        
        if hoursString.contains("Open 24 hours") {
            return "Open 24 hours"
        }
        
        return hoursString
    }
    
    func loadMiniMap() {
        guard let address = ammenitieDetails?.formattedAddress,
            let title = ammenitieDetails?.name else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location?.coordinate else { return }
            
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: 12)
            self.ammenityMapView.camera = camera
            self.ammenityMapView.mapType = GMSMapViewType.normal
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = title
            marker.snippet = address
            marker.map = self.ammenityMapView
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension Date {
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
