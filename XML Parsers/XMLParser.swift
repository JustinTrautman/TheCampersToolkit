//
//  XMLParser.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

struct Campgroundxml {
    
    var availabilityStatus: String?
    var contractType: String?
    var facilityID: String?
    var facilityName: String?
    var latitude: String?
    var longitude: String?
    var reservationChannel: String?
    var sitesWithAmps: String?
    var sitesWithPetsAllowed: String?
    var sitesWithSewerHookup: String?
    var sitesWithWaterHookup: String?
    var sitesWithWaterfront: String?
    var state: String?
}

class CampgroundParser: NSObject, XMLParserDelegate {
    
    private var campgrounds: [Campgroundxml] = []
    private var currentElement = ""
    private var currentAvailabilityStatus: String = ""
    private var currentContractType: String = ""
    private var currentFacilityID: String = ""
    private var currentFacilityName: String = ""
    private var currentLatitude: String = ""
    private var currentLongitude: String = ""
    private var currentReservatingChannel: String = ""
    private var currentSitesWithAmps: String = ""
    private var currentSitesWithPetsAllowed: String = ""
    private var currentSitesWithSewerHookup: String = ""
    private var currentSitesWithWaterHookup: String = ""
    private var currentSitesWithWaterFront: String = ""
    private var currentState: String = ""
    private var parserCompletionHandler: (([Campgroundxml]) -> Void)?
    
    func parseCampground(url: String, completionHandler: (([Campgroundxml]) -> Void)?) {
        
        self.parserCompletionHandler = completionHandler
        
        let urlString = "http://api.amp.active.com/camping/campgrounds/?pname=Alderwood+RV+Express&api_key=r6up4xpsz8eban6zcgr52vh8"
        let request = URLRequest(url: URL(string: urlString)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            
            // Parse XML data
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }
    
    // MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        if currentElement == "result" {
            currentAvailabilityStatus = ""
            currentContractType = ""
            currentFacilityID = ""
            currentFacilityName = ""
            currentLatitude = ""
            currentLongitude = ""
            currentReservatingChannel = ""
            currentSitesWithAmps = ""
            currentSitesWithPetsAllowed = ""
            currentSitesWithSewerHookup = ""
            currentSitesWithWaterFront = ""
            currentState = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch currentElement {
        case "availabilityStatus": currentAvailabilityStatus += string
        case "contractType": currentContractType += string
        case "facilityID": currentFacilityID += string
        case "facilityName": currentFacilityName += string
        case "latitude": currentLatitude += string
        case "longitude": currentLongitude += string
        case "reservationChannel": currentReservatingChannel += string
        case "sitesWithAmps": currentSitesWithAmps += string
        case "sitesWithPetsAllowed": currentSitesWithPetsAllowed += string
        case "sitesWithSewerHookup": currentSitesWithSewerHookup += string
        case "sitesWithWaterHookup": currentSitesWithWaterHookup += string
        case "sitesWithWaterfront": currentSitesWithWaterFront += string
        case "state": currentState += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "result" {
            let campground = Campgroundxml(availabilityStatus: currentAvailabilityStatus, contractType: currentContractType, facilityID: currentFacilityID, facilityName: currentFacilityName, latitude: currentLatitude, longitude: currentLongitude, reservationChannel: currentReservatingChannel, sitesWithAmps: currentSitesWithAmps, sitesWithPetsAllowed: currentSitesWithPetsAllowed, sitesWithSewerHookup: currentSitesWithSewerHookup, sitesWithWaterHookup: currentSitesWithWaterHookup, sitesWithWaterfront: currentSitesWithWaterFront, state: currentState)
            campgrounds += [campground]
//             self.campgrounds.append(campground)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        parserCompletionHandler?(campgrounds)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        print(parseError.localizedDescription)
    }
    
}
