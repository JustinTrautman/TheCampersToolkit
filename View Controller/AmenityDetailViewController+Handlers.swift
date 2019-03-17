/*
 ----------------------------------------------------------------------------------------
 
 AmenityDetailViewController+Handlers.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 3/16/19.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import Foundation

extension AmenityDetailViewController {
    
    @objc func handlePhoneLabelTap() {
        guard let phoneNumber = phoneNumberLabel.text?.digitsOnly else {
            return
        }
        OpenUrlHelper.call(phoneNumber: phoneNumber)
    }
    
    @objc func handleWebsiteLabelTap() {
        guard let website = amenitieDetails?.website else {
            return
        }
        OpenUrlHelper.openWebsite(with: website, on: self)
    }
    
    @objc func handleAmenityImageTap() {
        self.performSegue(withIdentifier: PhotoDetailViewController.segueIdentifier, sender: self)
    }
}
