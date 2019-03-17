/*
 ----------------------------------------------------------------------------------------
 
 TravelViewController+Handlers.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 3/14/19.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */


import Foundation

extension TravelViewController {
    
    @objc func handleGasStationButtonTap() {
        self.selectedType = "gas_station"
        self.performSegue(withIdentifier: AmenityMapViewController.segueIdentifier, sender: self)
    }
    
    @objc func handlePropaneButtonTap() {
        self.selectedType = "store"
        self.performSegue(withIdentifier: AmenityMapViewController.segueIdentifier, sender: self)
    }
    
    @objc func handleStoreButtonTap() {
        self.selectedType = "supermarket"
        self.performSegue(withIdentifier: AmenityMapViewController.segueIdentifier, sender: self)
    }
    
    @objc func handleCarRepairButtonTap() {
        self.selectedType = "car_repair"
        self.performSegue(withIdentifier: AmenityMapViewController.segueIdentifier, sender: self)
    }
}
