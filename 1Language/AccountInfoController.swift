//
//  AccountInfoController.swift
//  1Language
//
//  Created by Alan Valdez on 6/10/16.
//  Copyright © 2016 CTI. All rights reserved.
//

import Foundation

public class AccountInfoController {
    
    //Method used to get the Document file path to access AccountInfo.plist
    func plistFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentsDirectory = paths[0]
        
        return documentsDirectory + "/" + plistFileName
    }
    
    //Plist file name
    let plistFileName = "AccountInfo.plist"
    
    func getAccountInfo() -> NSDictionary {
        
        let filePath: String = AccountInfoController().plistFilePath()
        
        var accountInfo : NSDictionary = [:]
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            
            accountInfo = NSDictionary(contentsOfFile: filePath)!
        }
        
        return accountInfo
    }
}