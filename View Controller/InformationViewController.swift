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
        showTermsAlert()
    }
    @IBAction func supportButtonTapped(_ sender: Any) {
        showSupportAlert()
    }
    
    func showTermsAlert() {
        let termsOfServiceText = "The boondocking information found within this app is supported by public submission and therefore cannot be guarenteed to be accurate. Please research indivdual sites using the included phone number and website if available. Always check with local authorities to verify the legality of sites before boondocking. I agree that Modular Mobile LLC and its developers are not responsible for any inaccuracies of boondocking infomation"
        let termsAlertController = UIAlertController(title: nil, message: termsOfServiceText, preferredStyle: .alert)
        let understandAction = UIAlertAction(title: "I understand", style: .default, handler: nil)
        termsAlertController.addAction(understandAction)
        
        present(termsAlertController, animated: true)
    }
    
    func showSupportAlert() {
        let supportText = "You may send support questions, feature requests, or report any data inaccuracies to justin@modularmobile.net"
        let supportAlertController = UIAlertController(title: nil, message: supportText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        supportAlertController.addAction(okAction)
        
        present(supportAlertController, animated: true)
    }
}
