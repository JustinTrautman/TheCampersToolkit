/*
 ----------------------------------------------------------------------------------------
 
 BoondockDescriptionTableViewCell.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 10/11/18.
 Copyright © 2018 ModularMobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 ----------------------------------------------------------------------------------------
 */

import UIKit

class BoondockDescriptionTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
