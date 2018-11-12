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

class InformationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func termsOfServiceButtonTapped(_ sender: Any) {
        AlertHelper.showBoondockingTerms(on: self)
    }
    @IBAction func supportButtonTapped(_ sender: Any) {
        AlertHelper.showSupportAlert(on: self)
    }
}
