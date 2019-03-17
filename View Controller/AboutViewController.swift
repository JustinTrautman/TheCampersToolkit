/*
 ----------------------------------------------------------------------------------------
 
 InformationViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 9/30/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class AboutViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func termsOfServiceButtonTapped(_ sender: Any) {
        OpenUrlHelper.openWebsite(with: "https://modularmobile.net/boondocker-terms-of-use/", on: self)
    }
    @IBAction func supportButtonTapped(_ sender: Any) {
        AlertHelper.showSupportAlert(on: self)
    }
}
