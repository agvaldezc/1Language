//
//  ClientDashboardController.swift
//  1Language
//
//  Created by Alan Valdez on 6/10/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class ClientDashboardController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Method used to get the Document file path to access AccountInfo.plist
    func plistFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentsDirectory = paths[0]
        
        return documentsDirectory + "/" + plistFileName
    }
    
    //Plist file name
    let plistFileName = "AccountInfo.plist"
    
    //Action triggered by logout button to confirm logout
    @IBAction func logoutConfirmation() {
        let alert = AlertsController().confirmationAlert("Warning", alertMessage: "Do you really want to logout?", alertButton: "")
        
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Logout function after confirming logout
    func logout() -> Void {
        
        let filePath: String = self.plistFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            try! NSFileManager.defaultManager().removeItemAtPath(filePath)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("login")
            self.presentViewController(vc, animated: true, completion: nil)
            
        } else {
            print("Cannot logout")
        }
    }
}
