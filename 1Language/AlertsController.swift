//
//  AlertsController.swift
//  1Language
//
//  Created by Alan Valdez on 6/3/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import Foundation
import UIKit

//This class helps to make alerts easily with calling their methods and using the right properties
class AlertsController {
    
    //This methos return an error alert and you can attach a method to it after the confirmation button is pressed on the alert
    //Parameters:
    //alertTitle: String (Alert title)
    //alertMessage: String (Message to be desplayed by the alert)
    //alertButton: String (What the alert button will display)
    func errorAlert(alertTitle: String, alertMessage: String, alertButton: String) -> UIAlertController {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: alertButton, style: UIAlertActionStyle.Default, handler: nil))
        
        return alert
        
    }
    
    //This methos return an confirmation alert
    //Parameters:
    //alertTitle: String (Alert title)
    //alertMessage: String (Message to be desplayed by the alert)
    func confirmationAlert(alertTitle: String, alertMessage: String, alertButton: String) -> UIAlertController {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        return alert
    }
    
}