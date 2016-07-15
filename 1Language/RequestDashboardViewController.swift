//
//  RequestDashboardViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/21/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class RequestDashboardViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if (Reachability.isConnectedToNetwork()) {
            
            accountInfo = AccountInfoController().getAccountInfo()
            
            getRequests(accountInfo["profile"] as! String)
            
        } else {
            let alert = AlertsController().confirmationAlert("Error", alertMessage: "You are not connected to the internet. Please try again later.", alertButton: "Ok")
            
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var addRequestButton: UIBarButtonItem!
    var accountInfo : NSDictionary = [:]
    var requests : NSArray = []
    var selectedRequest : NSDictionary = [:]
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requests.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! RequestTableCell
        
        cell.request = requests[indexPath.row] as? NSDictionary
        
        cell.requestIDLabel.text = "Request ID: \((cell.request!["id"] as? String)!)"
        cell.patientNameLabel.text = "Patient: \((cell.request!["patientname"] as? String)!)"
        cell.languageLabel.text = "Language: \((cell.request!["language"] as? String)!)"
        cell.departmentLabel.text = "Department: \((cell.request!["department"] as? String)!)"
        
        let requestStatus = cell.request!["requeststatus"] as? String
        
        cell.statusLabel.text = "Status: \(requestStatus!)"
        
        switch (requestStatus!) {
        case "pending":
            cell.statusLabel.textColor = UIColor.orangeColor()
            break;
        case "cancelled":
            cell.statusLabel.textColor = UIColor.redColor()
            break;
        case "accepted":
            cell.statusLabel.textColor = UIColor.blueColor()
            break;
        case "complete":
            cell.statusLabel.textColor = UIColor.greenColor()
            break;
        default:
            break;
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(cell.request!["requestmade"] as! String)
        
        let correctFormat = NSDateFormatter()
        correctFormat.dateFormat = "MMM d, H:mm a"
        let stringDate = correctFormat.stringFromDate(date!)
        
        cell.dateLabel.text = "Appointment: \(stringDate)"
        
        return cell
    }
    
    @IBAction func refreshRequestDashboard(sender: AnyObject) -> Void {
        let alert = AlertsController().confirmationAlert("Alert", alertMessage: "Do you want to refresh your dashboard?", alertButton: "Ok")
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (UIAlertAction) in
            self.getRequests(self.accountInfo["profile"] as! String)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func refreshDashboard() -> Void {
        
    }
    
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "selectedRequestSegue") {
            let selectedRequestView = segue.destinationViewController as! SelectedRequestViewController
            
            selectedRequestView.request = selectedRequest
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = tableView.indexPathForSelectedRow
        
        let cell = tableView.cellForRowAtIndexPath(index!) as! RequestTableCell
        
        selectedRequest = cell.request!
        
        self.performSegueWithIdentifier("selectedRequestSegue", sender: self)
        
    }
    
    func getRequests(profile : String) {
        
        let bounds = UIScreen.mainScreen().bounds
        
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 100, height: 100)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        actInd.layer.cornerRadius = 10
        
        let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        
        actInd.backgroundColor = backgroundColor
        actInd.startAnimating()
        
        loadingView.addSubview(actInd)
        
        view.addSubview(loadingView)
        
        var urlData : String = ""
        
        switch profile {
        case "interpreter":
            
            //Remove add request button from dashboard
            self.navigationItem.rightBarButtonItem = nil
            
            urlData = "accounttype=\(profile)&username=\(accountInfo["username"] as! String)"
            
            break
            
        case "client":
            
            urlData = "accounttype=\(profile)&username=\(accountInfo["username"] as! String)"
            
            break
            
        case "coordinator":
            
            urlData = "accounttype=\(profile)"
            break
            
        case "manager":
            
            urlData = "accounttype=\(profile)"
            break
            
        default:
            break
        }
        
        let url = "http://app1anguage.consultinglab.com.mx/public/api/get-requests?\(urlData)"
        
        let convertedURL = NSURL(string: url)
        
        let data = NSData(contentsOfURL: convertedURL!)
        
        do
        {
            //Read response as json
            self.requests = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! NSArray
        }
        catch
        {
            print("error JSON: \(error)")
        }
        
        table.reloadData()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            actInd.stopAnimating()
            
            loadingView.removeFromSuperview()
        }
    }
}
