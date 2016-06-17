//
//  ProfileViewController.swift
//  1Language
//
//  Created by Alan Valdez on 6/17/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImage.image = UIImage(named: "noProfile")
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Labels that show required information
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var profileInfoContainer: UIView!
    
}
