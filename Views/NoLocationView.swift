//
//  NoLocationView.swift
//  TheCampersToolkit
//
//  Created by Justin Trautman on 3/10/19.
//  Copyright © 2019 Justin Trautman. All rights reserved.
//

import UIKit
import Lottie

class NoLocationView: UIView {
    
    override func awakeFromNib() {
        // Properties
        let animationView: LOTAnimationView = {
            let animation = LOTAnimationView(name: "noLocation")
            animation.layer.masksToBounds = true
            animation.play()
            animation.animationSpeed = 0.5
            animation.loopAnimation = true
            return animation
        }()
        
        let psstLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.layer.masksToBounds = true
            label.textColor = .white
            label.numberOfLines = 1
            label.text = "Psst!"
            label.font = UIFont(name: "ChalkboardSE-Bold", size: 40)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            return label
        }()
        
        let informationLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.layer.masksToBounds = true
            label.textColor = .white
            label.font = UIFont(name: "ChalkboardSE-Bold", size: 28)
            label.numberOfLines = 0
            label.text = "This app won't be very useful without location! Please turn it on in settings."
            label.lineBreakMode = .byTruncatingTail
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.2
            return label
        }()
        
        let locationSettingsButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.applyGreenTheme(buttonTitle: "Location Settings")
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            button.addTarget(self, action: #selector(handleSettingsRequest), for: .touchUpInside)
            return button
        }()
        
        // Some parent view setup
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        self.layer.cornerRadius = 10.0
        self.isOpaque = true
        
        // Setup animation view
        self.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
        animationView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Setup 'Psst' label
        self.addSubview(psstLabel)
        psstLabel.translatesAutoresizingMaskIntoConstraints = false
        psstLabel.centerYAnchor.constraint(equalTo: animationView.centerYAnchor).isActive = true
        psstLabel.leftAnchor.constraint(equalTo: animationView.rightAnchor, constant: 25).isActive = true
        psstLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        psstLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        // Setup information label
        self.addSubview(informationLabel)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        informationLabel.topAnchor.constraint(equalTo: psstLabel.bottomAnchor, constant: 5).isActive = true
        informationLabel.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
        informationLabel.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: 1/4).isActive = true
        
        // Setup location settings button
        self.addSubview(locationSettingsButton)
        locationSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        locationSettingsButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        locationSettingsButton.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 10).isActive = true
        locationSettingsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        locationSettingsButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
    }
    
    @objc func handleSettingsRequest() {
        OpenUrlHelper.openAppSettings()
    }
}
