//
//  ProfileTableViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/17/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        accountInfo = loadAccountInfo()
        
        if (accountInfo["middlename"] != nil) {
            nameLabel.text = "\(accountInfo["firstname"]!) \(accountInfo["middlename"]!) \(accountInfo["lastname"]!)"
        } else {
            nameLabel.text = "\(accountInfo["firstname"]!) \(accountInfo["lastname"]!)"
        }
        
        emailLabel.text = "\(accountInfo["email"]!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //Table cells
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var phoneCell: UITableViewCell!
    @IBOutlet weak var employeeIdCell: UITableViewCell!
    
    //Required info labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    //Optional info labels and titles
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var employeeIdTitle: UILabel!
    @IBOutlet weak var employeeIdLabel: UILabel!
    
    //Account Information dictionary
    var accountInfo : NSDictionary = [:]
    
    //Load account information from app
    func loadAccountInfo() -> NSDictionary {
        
        let filePath: String = AccountInfoController().plistFilePath()
        
        var info : NSDictionary = [:]
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            info = NSDictionary(contentsOfFile: filePath)!
        }
        
        return info
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
