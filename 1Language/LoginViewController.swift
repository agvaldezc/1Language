//
//  LoginViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/3/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function used to display corresponding view depending on account type
    func showAccountTypeView(accountType: String) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(accountType)
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    //Method used to get the Document file path to access AccountInfo.plist
    func plistFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentsDirectory = paths[0]
        
        return documentsDirectory + "/" + plistFileName
    }
    
    //Plist file name
    let plistFileName = "AccountInfo.plist"
    
    //Username and password field variables
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginAction(sender: AnyObject) {
        
        //Specify the messages we are going to use if there's any error
        var alertTitle = "Warning"
        var alertMessage = "You are not connected to the internet."
        var alertButton = "Ok"
        
        //Status of the operations made:
        // 0 Initial state
        // -1 Username or password not filled
        // -2 Username or password are not valid
        // 1 Username and password validation successfull
        var status = 0
        
        //Check if there is internet connection before doing anything
        if (Reachability.isConnectedToNetwork()) {
            
            //Validate that username and password are filled
            if (usernameField.text == "" || passwordField.text == "") {
                alertTitle = "Error"
                alertMessage = "Please enter a valid username and password"
                alertButton = "Ok"
                status = -1
                
                let alert = AlertsController().errorAlert(alertTitle, alertMessage: alertMessage, alertButton: alertButton)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            //Start request for server
            if (status == 0) {
                
                let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/auth")!)
                
                let appData = "username=\(usernameField.text!)&password=\(passwordField.text!)&source=application"
                
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
                    //The server responsed whit a bad status
//                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200
//                    {
//                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                        print("response = \(response)")
//                    }
                    
                    print("response =  \(response)")
                    
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("responseString = \(responseString)")
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        //We have a good response from the server
                        do
                        {
                            //Read response as json
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                            
                            //The status of login
                            print("\(jsonData["status"])")
                            
                            status = jsonData["status"] as! Int
                            
                            if status == -2 {
                                alertTitle = "Warning"
                                alertMessage = "Username or password is invalid"
                                alertButton = "Ok"
                                
                                let alert = AlertsController().errorAlert(alertTitle, alertMessage: alertMessage,alertButton: alertButton)
                                
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            }
                            else
                            {
                                //Go to nex screen and confirm login
                                let profile = jsonData["accounttype"] as? String
                                
                                let accountInfo = NSMutableDictionary()

                                accountInfo.setValue(jsonData["accounttype"] as? String, forKey: "profile")
                                accountInfo.setValue(jsonData["username"] as? String, forKey: "username")
                                accountInfo.setValue(jsonData["id"] as? String, forKey: "id")
                                accountInfo.setValue(jsonData["title"] as? String, forKey: "title")
                                accountInfo.setValue(jsonData["firstname"] as? String, forKey: "firstname")
                                accountInfo.setValue(jsonData["middlename"] as? String, forKey: "middlename")
                                accountInfo.setValue(jsonData["lastname"] as? String, forKey: "lastname")
                                accountInfo.setValue(jsonData["email"] as? String, forKey: "email")
                                
                                
                                
                                if (jsonData["phone"] as? String != nil) {
                                    accountInfo.setValue(jsonData["phone"] as? String, forKey: "phone")
                                } else {
                                    print("no phone")
                                    accountInfo.setValue("N/A", forKey: "phone")
                                }
                                
                                if (jsonData["employeeid"] as? String != nil) {
                                    accountInfo.setValue(jsonData["employeeid"] as? String, forKey: "employeeid")
                                } else {
                                    print("no employeeid")
                                    accountInfo.setValue("N/A", forKey: "employeeid")
                                }

                                accountInfo.writeToFile(self.plistFilePath(), atomically: true)
                                
                                switch profile! {
                                    case "coordinator":
                                        self.showAccountTypeView(profile!)
                                        break;
                                    case "client":
                                        self.showAccountTypeView(profile!)
                                        break;
                                    case "interpreter":
                                        self.showAccountTypeView(profile!)
                                        break;
                                    case "manager":
                                        self.showAccountTypeView(profile!)
                                        break;
                                    default:
                                        print ("Error on showing view with profile type \(profile!)")
                                        break;
                                }
                            }
                        }
                        catch
                        {
                            print("error JSON: \(error)")
                        }
                    })
                }
                task.resume()
            }
            
        } else {
    
            //Generate an alert using the AlertsController we made
            let alert = AlertsController().errorAlert(alertTitle, alertMessage: alertMessage,alertButton: alertButton)
            
            //Display alert on current view
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}
