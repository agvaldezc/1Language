//
//  ProfileViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/17/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let filePath: String = AccountInfoController().plistFilePath()
        
        uploadActivityMonitor.hidden = true
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            
            accountInfo = NSMutableDictionary(contentsOfFile: filePath)!
        }
        
        if (Reachability.isConnectedToNetwork()) {
            
            let url = NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/get-picture?username=\(accountInfo["username"] as! String)")

            //Get data from URL
            let data = NSData(contentsOfURL: url!)
            
            if (data == nil) {
                let alert = UIAlertController(title: "Error", message: "Could not load your profile picture.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                values = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            }
            
            if (values.count > 0) {
                
//                ImageLoader.sharedLoader.imageForUrl("http://app1anguage.consultinglab.com.mx/public/\(values[0]["picpath"] as! String)", completionHandler:{(image: UIImage?, url: String) in
//                    self.profileImage.image = image!
//                })
                
                let url = NSURL(string: "http://app1anguage.consultinglab.com.mx/public/\(values[0]["picpath"] as! String)")
                
                let picData = NSData(contentsOfURL: url!)
                
                profileImage.image = UIImage(data: picData!)
                profileImage.layer.cornerRadius = profileImage.frame.size.height/2
                
                profileImage.layer.borderWidth = 1
                profileImage.layer.masksToBounds = false
                profileImage.layer.borderColor = UIColor.blackColor().CGColor
                profileImage.layer.cornerRadius = profileImage.frame.height/2
                profileImage.clipsToBounds = true
                
            } else {
                profileImage.image = UIImage(named: "noProfile")
                profileImage.layer.cornerRadius = profileImage.frame.size.height/2
                profileImage.layer.borderWidth = 1
                profileImage.layer.masksToBounds = false
                profileImage.layer.borderColor = UIColor.blackColor().CGColor
                profileImage.layer.cornerRadius = profileImage.frame.height/2
                profileImage.clipsToBounds = true
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Could not load your profile picture.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            profileImage.image = UIImage(named: "noProfile")
            profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Account info dictionary
    var accountInfo : NSMutableDictionary = [:]
    
    //Values recovered from profilepicture table
    var values : NSArray = []
    
    //Global response string status
    var globalResponseString : String = ""
    
    //Activity monitor
    @IBOutlet weak var uploadActivityMonitor: UIActivityIndicatorView!
    
    //Labels that show required information
    @IBOutlet weak var profileImage: UIImageView!
    
    //Table container
    @IBOutlet weak var profileInfoContainer: UIView!
    
    @IBAction func profilePickMenu(sender: AnyObject) {
        //Action sheet
        let actionSheet = AlertsController().actionSheet("What do you want to do?")
        
        //Action sheet cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        //Action sheet upload button
        let uploadPicture = UIAlertAction(title: "Upload Profile Picture", style: .Default) { (UIAlertAction) in
            self.pickProfileImage()
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(uploadPicture)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func pickProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        ImageUploadRequest()
    }
    
    func ImageUploadRequest()
    {
        
        let myUrl = NSURL(string: "http://app1anguage.consultinglab.com.mx/public/api/upload-profile-picture");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let param = [
            "username" : accountInfo["username"] as! String
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(profileImage.image!, 1)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        uploadActivityMonitor.hidden = false
        uploadActivityMonitor.startAnimating()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in guard error == nil && data != nil else
            {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            self.globalResponseString = responseString as! String
            
            print("****** response data = \(responseString!)")
            
            dispatch_async(dispatch_get_main_queue(),{
                self.uploadActivityMonitor.stopAnimating()
                self.uploadActivityMonitor.hidden = true
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height/2
                
                self.checkUploadStatus()
            })
        }
        
        task.resume()
    }
    
    func checkUploadStatus() {
        if (globalResponseString == "Ok") {
            let alert = UIAlertController(title: "Alert", message: "Profile picture updated successfully.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Profile picture was not updated successfully.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "\(accountInfo["username"] as! String).jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

