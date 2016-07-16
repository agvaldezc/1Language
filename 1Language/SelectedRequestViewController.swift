//
//  SelectedRequestViewController.swift
//  1Language
//
//  Created by Alan Valdez on 7/6/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class SelectedRequestViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        languages = loadLanguages()
        departments = loadDepartments()
        
        print(languages[0]["languagename"])
        print(departments)
        
        prepareNavBar()
        prepareView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Request Information passed by segue
    var request : NSDictionary?
    
    //Navigation Title Controller
    @IBOutlet weak var requestNavItem: UINavigationItem!
    
    //Editable Fields
    @IBOutlet weak var MRNField: UITextField!
    @IBOutlet weak var patientNameField: UITextField!
    @IBOutlet weak var patientMRNField: UITextField!
    @IBOutlet weak var commentsField: UITextField!
    @IBOutlet weak var prescheduleDateField: UITextField!
    @IBOutlet weak var prescheduleReasonField: UITextField!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var genderPreferenceField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    
    //Navbar items
    var editButton = UIBarButtonItem()
    var saveChangesButton = UIBarButtonItem()
    
    //Info Labels
    @IBOutlet weak var requestMadeBy: UILabel!
    @IBOutlet weak var requestMadeLabel: UILabel!
    @IBOutlet weak var MRNLabel: UILabel!
    @IBOutlet weak var patientLabel: UILabel!
    @IBOutlet weak var patientMRNLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var prescheduleDateLabel: UILabel!
    @IBOutlet weak var prescheduleReasonLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var genderPreferenceLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    
    //Data input source arrays
    let genderPreferences = ["None", "Male", "Female"]
    var languages : NSArray = []
    var departments : NSArray = []
    
    //Picker view and date picker view declaration
    let pickerView = UIPickerView()
    let datePickerView = UIDatePicker()
    
    func enableEditMode(sender: UIBarButtonItem) {
        
        //Turn edit mode ON
        editMode(true)
        
        //For debug
        let alert = AlertsController().errorAlert("Alert", alertMessage: "Edit mode ON", alertButton: "Ok")
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        //Change navbar button
        requestNavItem.rightBarButtonItem = saveChangesButton
        
    }
    
    func saveChanges(sender: UIBarButtonItem) {
        
        //Turn edit mode OFF
        editMode(false)
        
        //For debug
        let alert = AlertsController().errorAlert("Alert", alertMessage: "Edit mode OFF", alertButton: "Ok")
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        //Change navbar button
        requestNavItem.rightBarButtonItem = editButton
    }
    
    func editMode(edit : Bool) -> Void {
        
        //Enable/Disable editable fields
        MRNField.hidden = !edit
        patientNameField.hidden = !edit
        patientMRNField.hidden = !edit
        commentsField.hidden = !edit
        prescheduleDateField.hidden = !edit
        prescheduleReasonField.hidden = !edit
        languageField.hidden = !edit
        genderPreferenceField.hidden = !edit
        departmentField.hidden = !edit
        
        //Enable/Disable info labels
        MRNLabel.hidden = edit
        patientLabel.hidden = edit
        patientMRNLabel.hidden = edit
        commentsLabel.hidden = edit
        prescheduleDateLabel.hidden = edit
        prescheduleReasonLabel.hidden = edit
        languageLabel.hidden = edit
        genderPreferenceLabel.hidden = edit
        departmentLabel.hidden = edit
        
    }
    
    func prepareView() -> Void {
        
        pickerView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: (#selector(SelectedRequestViewController.updatePicker)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        
        //Tap gesture to hide keyboard or input
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectedRequestViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        datePickerView.addTarget(self, action: #selector(SelectedRequestViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        prescheduleDateField.inputView = datePickerView
        languageField.inputView = pickerView
        genderPreferenceField.inputView = pickerView
        departmentField.inputView = pickerView
        
        //Who made the request
        requestMadeBy.text = "\(request!["clientname"]!)"
        
        //Request made date formatting--------
        let requestMadeDate = mysqlDateToSwift(request!["requestmade"] as! String)
        requestMadeLabel.text = "\(requestMadeDate)"
        //------------------------------------

        //MRN
        MRNLabel.text = "\(request!["mrn"]!)"
        MRNField.text = "\(request!["mrn"]!)"
        
        //Patient name
        patientLabel.text = "\(request!["patientname"]!)"
        patientNameField.text = "\(request!["patientname"]!)"
        
        //patient MRN if available
        if (request!["patientmrn"]! as? NSNull != NSNull()) {
            patientMRNLabel.text = "\(request!["patientmrn"]!)"
            patientMRNField.text = "\(request!["patientmrn"]!)"
        } else {
            patientLabel.text = "N/A"
        }
        
        //patient comments if available
        if (request!["comments"]! as? NSNull != NSNull()) {
            commentsLabel.text = "\(request!["comments"]!)"
            commentsField.text = "\(request!["comments"]!)"
        } else {
            commentsLabel.text = "N/A"
        }
        
        //Preschedule date if available
        if (request!["immediatepreschedule"]! as? NSNull != NSNull()) {
        
            let prescheduleDate = mysqlDateToSwift(request!["immediatepreschedule"] as! String)
            
            prescheduleDateLabel.text = "\(prescheduleDate)"
            prescheduleDateField.text = "\(prescheduleDate)"
            
        } else {
            prescheduleDateLabel.text = "N/A"
        }
        
        //Preschedule reason if any
        if (request!["preschedulereason"]! as? NSNull != NSNull()) {
            
            prescheduleReasonLabel.text = "\(request!["preschedulereason"]!)"
            prescheduleReasonField.text = "\(request!["preschedulereason"]!)"
            
        } else {
            prescheduleReasonLabel.text = "N/A"
        }
        
        //Language selected for request
        languageLabel.text = "\(request!["language"]!)"
        languageField.text = "\(request!["language"]!)"
        
        //Gender preference if any
        genderPreferenceLabel.text = "\(request!["genderpreference"]!)"
        genderPreferenceField.text = "\(request!["genderpreference"]!)"
        
        //Department selected
        departmentLabel.text = "\(request!["department"]!)"
        departmentField.text = "\(request!["department"]!)"
        
        //Start with edit mode OFF
        editMode(false)
    }
    
    func prepareNavBar() -> Void {
        
        //Assign actions to buttons
        editButton.action = #selector(enableEditMode)
        saveChangesButton.action = #selector(saveChanges)
        
        //Add target view to each button
        editButton.target = self
        saveChangesButton.target = self
        
        //Set title for each button
        editButton.title = "Edit"
        saveChangesButton.title = "Save"
        
        //Assign button to right side of navbar
        requestNavItem.rightBarButtonItem = editButton
        
        //Prepare navbar title
        requestNavItem.title = "Request No \(request!["id"]!)"
    }
    
    //Returns converted date string from MySQL format to any format you want
    func mysqlDateToSwift(mysqlDateString: String) -> String {
        
        let requestDateFormatter = NSDateFormatter()
        requestDateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let requestDate = requestDateFormatter.dateFromString(request!["requestmade"] as! String)
        
        requestDateFormatter.dateFormat = "EEEE, MMM d, yyyy HH:mm"
        let dateString = requestDateFormatter.stringFromDate(requestDate!)
        
        return dateString
    }
    
    //Load Departments from server
    func loadDepartments() -> NSArray {
        
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
    
    //Load languages from server
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
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (languageField.isFirstResponder() && languages.count > 0) {
            return languages.count
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferences.count
        } else if (departmentField.isFirstResponder() && departments.count > 0){
            return departments.count
        } else {
            return 1
        }

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (languageField.isFirstResponder() && languages.count > 0) {
            languageField.text = languages[row]["languagename"] as? String
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferenceField.text = genderPreferences[row]
        } else if (departmentField.isFirstResponder() && departments.count > 0){
            return departmentField.text = departments[row]["departmentname"] as? String
        } else {
            return
        }

        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (languageField.isFirstResponder() && languages.count > 0) {
            return languages[row]["languagename"] as? String
        } else if (genderPreferenceField.isFirstResponder()){
            return genderPreferences[row]
        } else if (departmentField.isFirstResponder() && departments.count > 0){
            return departments[row]["departmentname"] as? String
        } else {
            return "none"
        }

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func datePickerChanged(datePicker: UIDatePicker) {
        prescheduleDateField.text = formatDate(datePicker.date)
        //saveRequestButton.enabled = false
    }
    
    func formatDate(date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy HH:mm"
        
        return dateFormatter.stringFromDate(date)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        view.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
