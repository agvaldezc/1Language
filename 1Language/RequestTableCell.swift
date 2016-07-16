//
//  RequestTableCell.swift
//  1Language
//
//  Created by Alan Valdez on 7/5/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class RequestTableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        requestIDLabel.sizeToFit()
        patientNameLabel.sizeToFit()
        languageLabel.sizeToFit()
        departmentLabel.sizeToFit()
        statusLabel.sizeToFit()
        dateLabel.sizeToFit()
        
        requestIDLabel.adjustsFontSizeToFitWidth = true
        patientNameLabel.adjustsFontSizeToFitWidth = true
        languageLabel.adjustsFontSizeToFitWidth = true
        departmentLabel.adjustsFontSizeToFitWidth = true
        statusLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var requestIDLabel: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var request : NSDictionary?
    
}
