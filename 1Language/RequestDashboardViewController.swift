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
            self.refreshControl?.addTarget(self, action: #selector(RequestDashboardViewController.refreshDashboard), forControlEvents: UIControlEvents.ValueChanged)
            
            getRequests()
            
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
    var requests : NSMutableArray = []
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
    
    func refreshDashboard(refreshControl: UIRefreshControl) -> Void {
        getRequests()
        refreshControl.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! RequestTableCell
            
            let alert = UIAlertController(title: "Warning", message: "Do you really want to cancel this request?", preferredStyle: .ActionSheet)
            
            let cancelRequestAction = UIAlertAction(title: "Cancel Request", style: .Destructive, handler: { (UIAlertAction) in
                self.cancelRequest(cell.request!["id"] as! String)
            })
            
            let noAction = UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil)
            
            alert.addAction(cancelRequestAction)
            alert.addAction(noAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func cancelRequest(requestId: String) -> Void {
        if (Reachability.isConnectedToNetwork()) {
            let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/cancel-request")!)
            
            //Data to use in post method
            let appData = "requestId=\(requestId)"
            
            request.HTTPMethod = "POST"
            
            request.HTTPBody = appData.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            {
                //Error in session
                data,response, error in guard error == nil && data != nil else
                {
                    print("error=\(error)")
                    return
                }
                
                print("response =  \(response)")
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                print("responseString = \(responseString)")
                
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    //We have a good response from the server
                    do
                    {
                        //Read response as json
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        
                        let status = jsonData["status"] as! Int
                        
                        if (status > 0) {
                            let alert = AlertsController().confirmationAlert("Alert", alertMessage: "Your request has been canceled successfully.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        } else {
                            let alert = AlertsController().confirmationAlert("Error", alertMessage: "There was an error trying to cancel your request, please try again later.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    } catch {
                        print("error JSON: \(error)")
                    }
                })
            }
            
            task.resume()

        } else {
            let alert = AlertsController().confirmationAlert("Error", alertMessage: "You are not connected to the internet.", alertButton: "Ok")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Cancel \nRequest"
    }
    
    func getRequests() {
        
        let profile = accountInfo["profile"] as! String
        
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
            self.requests = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! NSMutableArray
        }
        catch
        {
            print("error JSON: \(error)")
        }
        
        table.reloadData()
    }
}
