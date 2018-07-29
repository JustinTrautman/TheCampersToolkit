//
//  TravelViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class TravelViewController: UIViewController {
    
    static let shared = TravelViewController()
    
    // MARK: - Properties
    var selectedType = "store"
    
    // MARK: - Actions
    @IBAction func gasButtonTapped(_ sender: Any) {
        selectedType = ""
        
        selectedType = "gas_station"
        print(selectedType)
    }
    
    @IBAction func propaneButtonTapped(_ sender: Any) {
        selectedType = ""
        
        selectedType = "store"
        print(selectedType)
    }
    
    @IBAction func supermarketButtonTapped(_ sender: Any) {
        selectedType = ""
        
        selectedType = "supermarket"
        print(selectedType)
    }
    
    @IBAction func carRepairButtonTapped(_ sender: Any) {
        selectedType = ""
        
        selectedType = "car_repair"
        print(selectedType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
