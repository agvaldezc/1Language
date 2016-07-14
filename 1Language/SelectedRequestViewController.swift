//
//  SelectedRequestViewController.swift
//  1Language
//
//  Created by Alan Valdez on 7/6/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class SelectedRequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavBar()
        prepareView()
        print(request!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    //Request Information passed by segue
    var request : NSDictionary?
    
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
        
        //Enable/Disable info labels
        MRNLabel.hidden = edit
        patientLabel.hidden = edit
        patientMRNLabel.hidden = edit
        commentsLabel.hidden = edit
        prescheduleDateLabel.hidden = edit
        prescheduleReasonLabel.hidden = edit
        languageLabel.hidden = edit
        genderPreferenceLabel.hidden = edit
        
    }
    
    func prepareView() -> Void {
        
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
            patientLabel.text = "\(request!["patientmrn"]!)"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
