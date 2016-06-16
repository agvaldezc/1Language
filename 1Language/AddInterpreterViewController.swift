//
//  AddUserViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/14/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class AddInterpreterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    //Form fields
    @IBOutlet weak var departmentField: UITextField!
    @IBOutlet weak var firstnamefield: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var middlenameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var employeeIdField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    //Created pickerView to use as value pickers for account type and
    //  department
    let pickerView = UIPickerView()
    
    //Picker data sources
    var departments : NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!Reachability.isConnectedToNetwork()) {
            
            let alert = AlertsController().confirmationAlert("Error", alertMessage: "You are not connected to the internet.", alertButton: "Ok")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            //Load departments from web platform
            departments = getDepartments()
            
            //Add event listener to check what textfield is clicked to change
            //  picker data
            NSNotificationCenter.defaultCenter().addObserver(self, selector: (#selector(AddInterpreterViewController.updatePicker)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
            
            //Tap gesture to hide keyboard or input
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddInterpreterViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
            
            //Make pickerView delegate our current view
            pickerView.delegate = self
            
            //Add our pickerView as our input source for these fields
            departmentField.inputView = pickerView
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        view.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (departmentField.isFirstResponder() && departments.count > 0) {
            return departments.count
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (departmentField.isFirstResponder() && departments.count > 0) {
            return departments[row]["departmentname"] as? String
        } else {
            return "none"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (departmentField.isFirstResponder() && departments.count > 0) {
            departmentField.text = departments[row]["departmentname"] as? String
        } else {
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    //Enable or disable optional fields in layout
    func textFieldDidEndEditing(textField: UITextField) {
        if (validInput()) {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    //Get departments from web platform
    func getDepartments() -> NSArray {
        
        //Initial empty array
        var values : NSArray = []
        
        //URL to recover departments
        let url = NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/get-departments")
        
        //Get data from URL
        let data = NSData(contentsOfURL: url!)
        
        //If data returned is null, show alert to say that service
        //  is unavailable and return to dashboard
        if (data == nil) {
            let alert = UIAlertController(title: "Error", message: "Could not load data from server. Service currently unavailable.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            values = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        }
        
        return values
    }
    
    
    @IBAction func registerUser() {
        
        if (!Reachability.isConnectedToNetwork()) {
            
            let alert = AlertsController().confirmationAlert("Error", alertMessage: "You are not connected to the internet.", alertButton: "Ok")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/register")!)
            
            //Data to use in post method
            var appData = "accountType=interpreter&firstname=\(firstnamefield.text!)&lastname=\(lastnameField.text!)&email=\(emailField.text!)&username=\(usernameField.text!)&password=\(passwordField.text!)&department=\(departmentField.text!)&phone=\(phoneField.text!)&employeeId=\(employeeIdField.text!)"
            
            if (middlenameField.text?.characters.count > 0) {
                appData += "&middlename=\(middlenameField.text!)"
            }
            
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
                        
                        //Response status from registering user
                        let status = jsonData["status"] as? Int
                        
                        if (status == -1) {
                            let alert = AlertsController().confirmationAlert("Error", alertMessage: "Username already taken.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        if (status == -2) {
                            let alert = AlertsController().confirmationAlert("Error", alertMessage: "Email already being used.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        if (status == -3) {
                            let alert = AlertsController().confirmationAlert("Error", alertMessage: "Server error.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        if (status == 1) {
                            let alert = AlertsController().confirmationAlert("Alert", alertMessage: "User registered sucessfully.", alertButton: "Ok")
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                                self.navigationController?.popViewControllerAnimated(true)
                            }))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    } catch {
                        print("error JSON: \(error)")
                        
                        let alert = AlertsController().confirmationAlert("Error", alertMessage: "Service is currently unavailable. Please try again later.", alertButton: "Ok")
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                            self.navigationController?.popViewControllerAnimated(true)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
            
            task.resume()
        }
    }
    
    func validInput() -> Bool {
        if (firstnamefield.text == "" || lastnameField.text == "" || emailField.text == "" || usernameField.text == "" || passwordField.text == "" || departmentField.text == "" || phoneField.text == "" || employeeIdField.text == "") {
            
            return false
            
        } else {
            
            return true
        }
    }
}

