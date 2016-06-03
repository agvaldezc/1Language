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
    
    //Username and password field variables
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginAction(sender: AnyObject) {
        
        //Specify the messages we are going to use if there's any error
        var alertTitle = "Warning"
        var alertMessage = "You are not connected to the internet."
        var alertButton = "Ok"
        
        //Status of the operations made:
        // 0 Nothing wrong
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
                
                let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/test")!)
                
                let appData = "/" + usernameField.text! + "/" + passwordField.text! + "/application"
                
                request.HTTPMethod = "GET"
                
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
                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200
                    {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        //We have a good response from the server
                        do
                        {
                            //Read response as json
                            let response = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                            //The status of login
                            print("\(response)")
                            status = 1
//                            if status != 1
//                            {
//                                alertTitle = "Warning"
//                                alertMessage = "Username or password is invalid"
//                                alertButton = "Accept"
//                            }
//                            else
//                            {
//                                //print("LOGEADO")
//                                let settings = NSUserDefaults.standardUserDefaults()
//                                settings.setObject(self.usernameField.text, forKey:"user")
//                                settings.setObject(self.passwordField.text, forKey:"password")
//                                settings.setObject(response["session"] as! String, forKey:"session")
//                                settings.setObject(response["profile"] as! String, forKey:"profile")
//                                settings.synchronize()
//                                //Go to nex screen
//                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                let vc = storyboard.instantiateViewControllerWithIdentifier("home")
//                                self.presentViewController(vc, animated: true, completion: nil)
//                            }
                        }
                        catch
                        {
                            print("error JSON: \(error)")
                        }
                        //print("second action \(status)")
                        
                        //If status is true then save the credentials and go to next screen
                        if status == 1
                        {
                            alertTitle = "Alert"
                            alertMessage = "Login successful"
                            alertButton = "Ok"
                            
                            let alert = AlertsController().errorAlert(alertTitle, alertMessage: alertMessage,alertButton: alertButton)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
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