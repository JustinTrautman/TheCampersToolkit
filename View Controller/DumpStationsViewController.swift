/*
 ----------------------------------------------------------------------------------------
 
 DumpStationsViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 3/11/19.
 Copyright © 2019 Justin Trautman. All rights reserved.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import StoreKit

class DumpStationsViewController: UIViewController {
    
    // MARK: Layout Properties
    let appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "rvDumpStationFinder")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "RV Dump Station Finder"
        label.font = UIFont(name: "HoeflerText-BlackItalic", size: 30)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let featuresLabel: UILabel = {
        let label = UILabel()
        label.text = "Features"
        label.font = UIFont(name: "Optima-ExtraBlack", size: 22)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let locationNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "• Over 2,000 dump station locations"
        label.font = UIFont(name: "system", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "• Filter dump stations by free and paid"
        label.font = UIFont(name: "system", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let seeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "• Detailed description of every dump station"
        label.font = UIFont(name: "system", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let searchFunctionalityLabel: UILabel = {
        let label = UILabel()
        label.text = "• Plan dump stations along your route"
        label.font = UIFont(name: "system", size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    let downloadOnTheAppStoreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "downloadOnTheAppStore"), for: .normal)
        button.addTarget(self, action: #selector(handleAppStoreButtonTap), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppIconImageView()
        setupAppNameLabel()
        setupFeaturesLabel()
        setupLocationNumberLabel()
        setupFilterLabel()
        setupSeeDescriptionLabel()
        setupSearchFunctionalityLabel()
        setupDownloadOnTheAppStoreButton()
    }
    
    // MARK: View Layout Functions
    func setupAppIconImageView() {
        view.addSubview(appIconImageView)
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        appIconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        appIconImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        appIconImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupAppNameLabel() {
        view.addSubview(appNameLabel)
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        appNameLabel.leadingAnchor.constraint(equalTo: appIconImageView.trailingAnchor, constant: 10).isActive = true
        appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        appNameLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
    }
    
    func setupFeaturesLabel() {
        view.addSubview(featuresLabel)
        featuresLabel.translatesAutoresizingMaskIntoConstraints = false
        featuresLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        featuresLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 15).isActive = true
        featuresLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
        featuresLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupLocationNumberLabel() {
        view.addSubview(locationNumberLabel)
        locationNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        locationNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationNumberLabel.topAnchor.constraint(equalTo: featuresLabel.bottomAnchor, constant: 10).isActive = true
        locationNumberLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
    }
    
    func setupFilterLabel() {
        view.addSubview(filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        filterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        filterLabel.topAnchor.constraint(equalTo: locationNumberLabel.bottomAnchor, constant: 10).isActive = true
        filterLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
    }
    
    func setupSeeDescriptionLabel() {
        view.addSubview(seeDescriptionLabel)
        seeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        seeDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeDescriptionLabel.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 10).isActive = true
        seeDescriptionLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
    }
    
    func setupSearchFunctionalityLabel() {
        view.addSubview(searchFunctionalityLabel)
        searchFunctionalityLabel.translatesAutoresizingMaskIntoConstraints = false
        searchFunctionalityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchFunctionalityLabel.topAnchor.constraint(equalTo: seeDescriptionLabel.bottomAnchor, constant: 10).isActive = true
        searchFunctionalityLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10).isActive = true
    }
    
    func setupDownloadOnTheAppStoreButton() {
        view.addSubview(downloadOnTheAppStoreButton)
        downloadOnTheAppStoreButton.translatesAutoresizingMaskIntoConstraints = false
        downloadOnTheAppStoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        downloadOnTheAppStoreButton.topAnchor.constraint(equalTo: searchFunctionalityLabel.bottomAnchor, constant: 15).isActive = true
        downloadOnTheAppStoreButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        downloadOnTheAppStoreButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    // MARK: Handlers
    @objc func handleAppStoreButtonTap() {
        OpenUrlHelper.openAppStoreItem(with: "1453722688", on: self)
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension DumpStationsViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        DispatchQueue.main.async {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}

