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
        
        
        print(request)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var request : NSDictionary?
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
