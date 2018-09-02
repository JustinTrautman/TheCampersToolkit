/*
 ----------------------------------------------------------------------------------------
 
 TravelViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/28/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class TravelViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var gasStationButton: UIButton!
    @IBOutlet weak var propaneButton: UIButton!
    @IBOutlet weak var supermarketButton: UIButton!
    @IBOutlet weak var carRepairButton: UIButton!
    
    // MARK: - Properties
    var selectedType = ""

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        guard let detailVC = segue.destination as? TravelMapViewController else { return }
        
        if segue.identifier == "toGasMap" {
            selectedType = "gas_station"
        }
        
        if segue.identifier == "toPropaneMap" {
            selectedType = "store"
        }
        
        if segue.identifier == "toStoreMap" {
            selectedType = "supermarket"
        }
        
        if segue.identifier == "toCarRepairMap" {
            selectedType = "car_repair"
        }
     
        detailVC.selectedType = selectedType
    }
}
