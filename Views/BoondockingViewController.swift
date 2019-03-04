/*
 ----------------------------------------------------------------------------------------
 
 BoondockingViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import StoreKit

class BoondockingViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var appStoreDownloadButton: UIButton!
    
    // MARK: View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appIconImageView.layer.cornerRadius = 20.0
        
        appStoreDownloadButton.addTarget(self, action: #selector(handleAppStoreButtonTap), for: .touchUpInside)
    }
    
    @objc func handleAppStoreButtonTap() {
        // TODO: Replace with Boondocker App id when released
        OpenUrlHelper.openAppStoreItem(with: "1453722688", on: self)
    }
}

extension BoondockingViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

