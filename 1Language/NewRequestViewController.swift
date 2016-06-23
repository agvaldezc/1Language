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
            
            pickerView.delegate = self
            
            languageField.inputView = pickerView
            genderPreferenceField.inputView = pickerView
            
        } else {
            
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
    
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var patientNameField: UITextField!
    @IBOutlet weak var patientMRNField: UITextField!
    @IBOutlet weak var MRNField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var genderPreferenceField: UITextField!
    
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
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (languageField.isFirstResponder() && languages.count > 0) {
            return languages[row]["languagename"] as? String
        } else {
            return "none"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (languageField.isFirstResponder() && languages.count > 0) {
            languageField.text = languages[row]["languagename"] as? String
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
}
