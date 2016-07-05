//
//  RequestDashboardViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/21/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class RequestDashboardViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if (Reachability.isConnectedToNetwork()) {
            
            accountInfo = AccountInfoController().getAccountInfo()
            
            let profile = accountInfo["profile"] as! String
            
            switch profile {
            case "interpreter":
                
                //Remove add request button from dashboard
                self.navigationItem.rightBarButtonItem = nil
                
                let urlData = "accounttype=\(profile)&username=\(accountInfo["username"] as! String)"
                
                requests = getRequests(urlData)
                break
            
            case "client":
                
                let urlData = "accounttype=\(profile)&username=\(accountInfo["username"] as! String)"
                
                requests = getRequests(urlData)
                break
                
            case "coordinator":
               
                let urlData = "accounttype=\(profile)"
                requests = getRequests(urlData)
                break
            
            case "manager":
                
                let urlData = "accounttype=\(profile)"
                requests = getRequests(urlData)
                break
                
            default:
                break
            }
            
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
    
    func getRequests(urlData : String) -> NSArray {
        
        var requests : NSArray = []
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/get-requests")!)
        
        let appData = urlData
        
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
                    requests = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! NSArray
                    

                }
                catch
                {
                    print("error JSON: \(error)")
                }
            })
        }
        task.resume()
        
        return requests
    }
}
