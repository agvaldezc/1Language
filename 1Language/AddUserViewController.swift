//
//  AddUserViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/14/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    
    //Special Field uses
    @IBOutlet weak var employeeLabel: UILabel!
    
    @IBOutlet weak var accountTypeField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    @IBOutlet weak var employeeField: UITextField!
    @IBOutlet weak var firstnamefield: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var validUsername = false
    
    //Created pickerView to use as value pickers for account type and
    //  department
    let pickerView = UIPickerView()
    
    //Picker data sources
    let accountTypes = ["Interpreter", "Coordinator", "Client", "Manager"]
    var departments : NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load departments from web platform
        departments = getDepartments()
        
        usernameField.addTarget(self, action: #selector(AddUserViewController.validateUsername), forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
        //Add event listener to check what textfield is clicked to change
        //  picker data
         NSNotificationCenter.defaultCenter().addObserver(self, selector: (#selector(AddUserViewController.updatePicker)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        
        //Tap gesture to hide keyboard or input
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddUserViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Make pickerView delegate our current view
        pickerView.delegate = self
        
        //Add our pickerView as our input source for these fields
        accountTypeField.inputView = pickerView
        departmentField.inputView = pickerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (accountTypeField.isFirstResponder()) {
            return accountTypes.count
        } else if (departmentField.isFirstResponder() && departments.count > 0) {
            return departments.count
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (accountTypeField.isFirstResponder()) {
            return accountTypes[row]
        } else if (departmentField.isFirstResponder() && departments.count > 0) {
            return departments[row]["departmentname"] as? String
        } else {
            return "none"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (accountTypeField.isFirstResponder()) {
            accountTypeField.text = accountTypes[row]
        } else if (departmentField.isFirstResponder() && departments.count > 0) {
            departmentField.text = departments[row]["departmentname"] as? String
        } else {
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    //Enable or disable optional fields in layout
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == accountTypeField) {
            if (accountTypeField.text == "Interpreter") {
                employeeField.enabled = true
                employeeLabel.enabled = true
            } else {
                employeeField.enabled = false
                employeeLabel.enabled = false
            }
        }
        
        if (textField == usernameField) {
            print("username text field")
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
    
    func validateInput() {
        
    }
    
    func validateUsername() {
        
        let stringURL = "http://app1anguage.consultinglab.com.mx/public/api/validate-username?username=\(usernameField.text!)&accountType=\(accountTypeField.text!)"
        
        let url = NSURL(string: stringURL)
        
        let data = NSData(contentsOfURL: url!)
        
        if (data == nil) {
            let alert = AlertsController().errorAlert("Error", alertMessage: "Could not validate username.", alertButton: "Ok")
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            validUsername = false
            
        } else {
            let values = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            print(stringURL)
            print(values)
            
            if (values[0]["valid"] as? Int == 0) {
                let alert = AlertsController().errorAlert("Error", alertMessage: "Username already taken.", alertButton: "Ok")
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                validUsername = false
                
            } else if (values[0]["valid"] as? Int == 1) {
                let alert = AlertsController().errorAlert("Sucess", alertMessage: "Username is valid", alertButton: "Ok")
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                validUsername = true
            }
        }
        
    }
}
