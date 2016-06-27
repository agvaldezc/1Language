//
//  NewRequestViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/21/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class NewRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: (#selector(NewRequestViewController.updatePicker)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        
        //Tap gesture to hide keyboard or input
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewRequestViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if (Reachability.isConnectedToNetwork()) {
            
            languages = loadLanguages()
            
            accountInfo = AccountInfoController().getAccountInfo()
            
            pickerView.delegate = self
            
            languageField.inputView = pickerView
            genderPreferenceField.inputView = pickerView
            
            genderPreferenceField.text = "None"
            
//            let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
//            
//            toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
//            
//            toolBar.barStyle = UIBarStyle.BlackTranslucent
//            
//            toolBar.tintColor = UIColor.whiteColor()
//            
//            toolBar.backgroundColor = UIColor.blackColor()
//            
//            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
//            
//            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
//            
//            label.font = UIFont(name: "Helvetica", size: 12)
//            
//            label.backgroundColor = UIColor.clearColor()
//            
//            label.textColor = UIColor.whiteColor()
//            
//            label.text = "Select a due date"
//            
//            label.textAlignment = NSTextAlignment.Center
//            
//            let textBtn = UIBarButtonItem(customView: label)
//            
//            toolBar.setItems([flexSpace,textBtn,flexSpace], animated: true)
//            
//            languageField.inputAccessoryView = toolBar
            
        } else {
            
            let alert = AlertsController().confirmationAlert("Error", alertMessage: "You are not connected to the internet.", alertButton: "Ok")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
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
    
    //Picker data Sources
    let genderPreferences = ["None", "Male", "Female"]
    var languages : NSArray = []
    
    //Picker view creation
    let pickerView = UIPickerView()
    
    //Account info
    var accountInfo : NSDictionary = [:]
    
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var patientNameField: UITextField!
    @IBOutlet weak var patientMRNField: UITextField!
    @IBOutlet weak var MRNField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var genderPreferenceField: UITextField!
    @IBOutlet weak var prescheduleDateField: UITextField!
    @IBOutlet weak var prescheduleReasonField: UITextField!
    
    @IBOutlet weak var prescheduleReasonLabel: UILabel!
    @IBOutlet weak var saveRequestButton: UIBarButtonItem!
    
    @IBAction func saveRequest(sender: AnyObject) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/make-interpreter-request")!)
        
        //Data to use in post method
        var appData = "language=\(languageField.text!)&patientName=\(patientNameField.text!)&MRN=\(MRNField.text!)&genderPreference=\(genderPreferenceField.text!)&clientId=\(accountInfo["username"])&clientFirstname=\(accountInfo["firstname"])&clientLastname=\(accountInfo["lastname"])"
        
        if (notesField.text?.characters.count > 0) {
            appData += "&comments=\(notesField.text!)"
        }
        
        if (prescheduleDateField.text?.characters.count > 0) {
            appData += "&prescheduleDate=\(prescheduleDateField.text!)&prescheduleReason=\(prescheduleReasonField.text!)"
        }
        
        if (accountInfo["middlename"] != nil) {
            appData += "&clientMiddlename=\(accountInfo["middlename"])"
        }
        
        print(appData)
        
//        request.HTTPMethod = "POST"
//        
//        request.HTTPBody = appData.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
//        {
//            //Error in session
//            data,response, error in guard error == nil && data != nil else
//            {
//                print("error=\(error)")
//                return
//            }
//        }
    }
    
    func loadLanguages() -> NSArray {
        
        //Initial empty array
        var values : NSArray = []
        
        //URL to recover departments
        let url = NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/get-languages")
        
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (languageField.isFirstResponder() && languages.count > 0) {
            return languages.count
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferences.count
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (languageField.isFirstResponder() && languages.count > 0) {
            return languages[row]["languagename"] as? String
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferences[row]
        } else {
            return "none"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (languageField.isFirstResponder() && languages.count > 0) {
            languageField.text = languages[row]["languagename"] as? String
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferenceField.text = genderPreferences[row]
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
        if (prescheduleDateField.text?.characters.count > 0) {
            prescheduleReasonField.enabled = true
            prescheduleReasonField.placeholder = "Required"
            prescheduleReasonLabel.enabled = true
            
        } else {
            prescheduleReasonField.enabled = false
            prescheduleReasonField.placeholder = ""
            prescheduleReasonLabel.enabled = false
        }
        
        saveRequestButton.enabled = validInput()
    }
    
    func validInput() -> Bool {
        if (languageField.text == "" || patientNameField.text == "" || MRNField.text == "" || (prescheduleReasonField.enabled && prescheduleReasonField.text == "")) {
            return false
            
        } else {
            return true
        }
    }
}
