//
//  TravelViewController.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 7/28/18.
//  Copyright © 2018 Justin Trautman. All rights reserved.
//

import UIKit

class TravelViewController: UIViewController {
    
    // MARK: - Properties
    var selectedType = "store"
    
    // MARK: - Actions
    @IBAction func gasButtonTapped(_ sender: Any) {
  
        selectedType = "gas_station"
        print(selectedType)
    }
    
    @IBAction func propaneButtonTapped(_ sender: Any) {
        
        selectedType = "store"
        print(selectedType)
    }
    
    @IBAction func supermarketButtonTapped(_ sender: Any) {
        
        selectedType = "supermarket"
         print(selectedType)
    }
    
    @IBAction func carRepairButtonTapped(_ sender: Any) {
        
        selectedType = "car_repair"
         print(selectedType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        guard let detailVC = segue.destination as? TravelMapViewController else { return }
        detailVC.selectedType = selectedType
    }
}
