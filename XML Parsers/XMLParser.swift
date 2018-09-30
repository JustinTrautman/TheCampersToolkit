//
//  XMLParser.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import Foundation

struct Campgroundxml {
    var availabilityStatus: String
    var contractType: String
    var facilityID: String
    var facilityName: String
    var latitude: String
    var longitude: String
    var reservationChannel: String
    var sitesWithAmps: String
    var sitesWithPetsAllowed: String
    var sitesWithSewerHookup: String
    var sitesWithWaterHookup: String
    var sitesWithWaterfront: String
    var state: String
}

class CampgroundParser: NSObject, XMLParserDelegate {
    
//    var campground: Campgroundxml?
    
    private var campgroundsxml: [Campgroundxml] = []
    private var currentElement = "" {
        didSet {
            print("\(currentElement)<<<<<<<<<<<<<<,")
        }
    }
    
    private var currentAvailabilityStatus = ""
    private var currentContractType = ""
    private var currentFacilityID = ""
    private var currentFacilityName = ""
    private var currentLatitude = ""
    private var currentLongitude = ""
    private var currentReservatingChannel = ""
    private var currentSitesWithAmps = ""
    private var currentSitesWithPetsAllowed = ""
    private var currentSitesWithSewerHookup = ""
    private var currentSitesWithWaterHookup = ""
    private var currentSitesWithWaterfront = ""
    private var currentState = ""
    private var parserCompletionHandler: (([Campgroundxml]) -> Void)?
    
    func parseCampground(url: String, completionHandler: (([Campgroundxml]) -> Void)?) {
        self.parserCompletionHandler = completionHandler
        
        let urlString = "\(url.utf8)".replacingOccurrences(of: " ", with: "+")
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
            //            campground = Campgroundxml(stringDictionary: attributeDict)
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
            currentSitesWithWaterfront = ""
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
        case "sitesWithWaterfront": currentSitesWithWaterfront += string
        case "state": currentState += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "result" {
            let campground = Campgroundxml(availabilityStatus: currentAvailabilityStatus, contractType: currentContractType, facilityID: currentFacilityID, facilityName: currentFacilityName, latitude: currentLatitude, longitude: currentLongitude, reservationChannel: currentReservatingChannel, sitesWithAmps: currentSitesWithAmps, sitesWithPetsAllowed: currentSitesWithPetsAllowed, sitesWithSewerHookup: currentSitesWithSewerHookup, sitesWithWaterHookup: currentSitesWithWaterHookup, sitesWithWaterfront: currentSitesWithWaterfront, state: currentState)
            
            self.campgroundsxml.append(campground)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(campgroundsxml)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
